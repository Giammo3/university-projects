#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/shm.h>
#include <sys/wait.h>
#include <openssl/sha.h>
#include "protocol.h"

//semaforo (System V)
#include <sys/sem.h>
union semun { int val; struct semid_ds *buf; unsigned short *array; };

static int qid, semid;
static int current_processes = 0; //solo per log

//coda richieste (SJF)
#define MAX_REQ 128
struct item { int shmid; size_t size; long reply_type; };
static struct item queue[MAX_REQ];
static int qlen = 0;

static void sha256_buf(const unsigned char *data, size_t len, char out_hex[65]) {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_CTX ctx;
    SHA256_Init(&ctx);
    SHA256_Update(&ctx, data, len);
    SHA256_Final(hash, &ctx);
    for (int i=0;i<SHA256_DIGEST_LENGTH;i++) sprintf(out_hex + 2*i, "%02x", hash[i]);
    out_hex[64] = '\0';
}

static void sem_P() {
    struct sembuf op = {0, -1, 0};
    if (semop(semid, &op, 1) == -1) { perror("semop P"); exit(1); }
}
static void sem_V() {
    struct sembuf op = {0, +1, 0};
    if (semop(semid, &op, 1) == -1) { perror("semop V"); exit(1); }
}

static void enqueue(int shmid, size_t size, long reply_type) {
    if (qlen < MAX_REQ) {
        queue[qlen++] = (struct item){shmid, size, reply_type};
        printf("Accodata richiesta: size=%zu shmid=%d reply=%ld (queue=%d)\n",
               size, shmid, reply_type, qlen);
    } else {
        fprintf(stderr, "Coda piena: richiesta scartata\n");
    }
}

static int pick_sjf_index() {
    if (qlen == 0) return -1;
    int best = 0;
    for (int i=1;i<qlen;i++) if (queue[i].size < queue[best].size) best = i;
    return best;
}

static void launch_if_possible() {
    //prova a lanciare finché c'è capienza sul semaforo e richieste in coda
    while (qlen > 0) {
        int idx = pick_sjf_index();
        struct item it = queue[idx];
        //compatta la coda
        for (int j=idx; j<qlen-1; j++) queue[j] = queue[j+1];
        qlen--;
        //P(sem): occupa uno slot worker
        sem_P();
        pid_t pid = fork();
        if (pid == 0) { //child
            void *p = shmat(it.shmid, NULL, 0);
            if (p == (void*)-1) { perror("shmat child"); sem_V(); exit(1); }

            char hex[65];
            sha256_buf((unsigned char*)p, it.size, hex);

            //risposta al client
            struct resp_msg resp; 
            resp.msg_type = it.reply_type;
            strncpy(resp.hash_hex, hex, 65);
            if (msgsnd(qid, &resp, sizeof(resp) - sizeof(long), 0) == -1) {
                perror("msgsnd resp");
            }

            //cleanup SHM
            shmdt(p);
            shmctl(it.shmid, IPC_RMID, NULL);

            //libera slot worker
            sem_V();
            _exit(0);
        } else if (pid > 0) {
            current_processes++;
            printf("  Fork PID=%d  (attivi≈%d)  size=%zu shmid=%d\n",
                   pid, current_processes, it.size, it.shmid);
            return;
        } else {
            perror("fork");
            //errore: restituisci slot
            sem_V();
        }
    }
}

static void on_child_exit(int sig) {
    int status;
    while (waitpid(-1, &status, WNOHANG) > 0) {
        current_processes--;
        printf("!! Figlio terminato. Attivi≈%d\n", current_processes);
        launch_if_possible();
    }
}

int main() {
    signal(SIGCHLD, on_child_exit);

    //coda messaggi
    key_t qkey = ftok(FTOK_PATH, Q_KEY_ID);
    qid = msgget(qkey, 0666 | IPC_CREAT);
    if (qid == -1) { perror("msgget"); return 1; }

    //semaforo con limite iniziale = 2
    key_t semkey = ftok(FTOK_PATH, SEM_KEY_ID);
    semid = semget(semkey, 1, 0666 | IPC_CREAT);
    if (semid == -1) { perror("semget"); return 1; }

    //inizializza solo se nuovo (best effort): prova a leggere, se fallisce setta
    union semun su;
    su.val = 2;
    semctl(semid, 0, SETVAL, su);

    printf("🔵 Server attivo (limite iniziale = %d tramite semaforo)\n", su.val);

    while (1) {
        //riceve sia req che admin
        //Usa il "tipo 0" per ricevere qualunque msg_type
        char raw[sizeof(struct req_msg) > sizeof(struct admin_msg) ? sizeof(struct req_msg) : sizeof(struct admin_msg)];
        long rcv_type = 0;
        ssize_t r = msgrcv(qid, raw, sizeof(raw), rcv_type, 0);
        if (r == -1) {
            if (errno == EINTR) continue;
            perror("msgrcv");
            break;
        }

        long mtype = *(long*)raw;
        if (mtype == MSGTYPE_ADMIN) {
            struct admin_msg *adm = (struct admin_msg*)raw;
            if (adm->new_limit > 0) {
                union semun s; s.val = adm->new_limit;
                if (semctl(semid, 0, SETVAL, s) == -1) perror("semctl SETVAL");
                else printf("!! Nuovo limite worker = %d (semaforo)\n", adm->new_limit);
            }
        } else if (mtype == MSGTYPE_REQUEST) {
            struct req_msg *req = (struct req_msg*)raw;
            enqueue(req->shmid, req->size, req->reply_type);
            launch_if_possible();
        } else {
            fprintf(stderr, " Messaggio sconosciuto (type=%ld)\n", mtype);
        }
    }
    return 0;
}

