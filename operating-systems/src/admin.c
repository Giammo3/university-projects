#include <stdio.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include "protocol.h"

int main(int argc, char *argv[]) {
    if (argc < 2) { printf("Uso: %s <nuovo_limite>\n", argv[0]); return 1; }
    int limit = atoi(argv[1]);
    if (limit <= 0) { printf("Limite non valido\n"); return 1; }

    key_t qkey = ftok(FTOK_PATH, Q_KEY_ID);
    int qid = msgget(qkey, 0666 | IPC_CREAT);
    if (qid == -1) { perror("msgget"); return 1; }

    struct admin_msg m;
    m.msg_type = MSGTYPE_ADMIN;
    m.new_limit = limit;

    if (msgsnd(qid, &m, sizeof(m) - sizeof(long), 0) == -1) {
        perror("msgsnd");
        return 1;
    }
    printf(" Richiesto nuovo limite worker = %d\n", limit);
    return 0;
}
