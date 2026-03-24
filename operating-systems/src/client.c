#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/shm.h>
#include <unistd.h>
#include "protocol.h"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Uso: %s <file_input>\n", argv[0]);
        return 1;
    }

    //legge file
    FILE *fp = fopen(argv[1], "rb");
    if (!fp) { perror("fopen"); return 1; }
    char *buf = malloc(SHM_MAX);
    if (!buf) { perror("malloc"); return 1; }
    size_t n = fread(buf, 1, SHM_MAX, fp);
    fclose(fp);

    //Crea SHM privata per questa richiesta
    int shmid = shmget(IPC_PRIVATE, n, 0666 | IPC_CREAT);
    if (shmid == -1) { perror("shmget"); free(buf); return 1; }
    void *shm = shmat(shmid, NULL, 0);
    if (shm == (void*)-1) { perror("shmat"); return 1; }
    memcpy(shm, buf, n);
    free(buf);

    //Coda messaggi
    key_t qkey = ftok(FTOK_PATH, Q_KEY_ID);
    int qid = msgget(qkey, 0666 | IPC_CREAT);
    if (qid == -1) { perror("msgget"); return 1; }

    //Invia richiesta con reply_type = PID
    struct req_msg req;
    req.msg_type = MSGTYPE_REQUEST;
    req.shmid = shmid;
    req.size = n;
    req.reply_type = (long)getpid();

    if (msgsnd(qid, &req, sizeof(req) - sizeof(long), 0) == -1) {
        perror("msgsnd");
        return 1;
    }
    printf("Inviata richiesta: shmid=%d, size=%zu, reply_type=%ld\n",
           shmid, n, req.reply_type);

    //Attende risposta su msg_type = reply_type
    struct resp_msg resp;
    if (msgrcv(qid, &resp, sizeof(resp) - sizeof(long), req.reply_type, 0) == -1) {
        perror("msgrcv");
        return 1;
    }
    printf("!! SHA-256: %s\n", resp.hash_hex);

    shmdt(shm);
    return 0;
}

