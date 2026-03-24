#ifndef PROTOCOL_H
#define PROTOCOL_H

#include <sys/types.h>
#include <stddef.h>

#define MSG_SIZE 128
#define SHM_MAX  4096
#define FTOK_PATH "/tmp"
#define Q_KEY_ID   65
#define SHM_KEY_ID 75
#define SEM_KEY_ID 85

// message types
#define MSGTYPE_REQUEST 1      
#define MSGTYPE_ADMIN   99     

//Messaggio di richiesta: server risponde su msg_type = reply_type
struct req_msg {
    long msg_type;     
    int  shmid;        
    size_t size;       
    long reply_type;   
};

//Messaggio admin (set limite)
struct admin_msg {
    long msg_type;    
    int  new_limit;    
};

//Messaggio risposta con hash esadecimale
struct resp_msg {
    long msg_type;     
    char hash_hex[65]; 
};

#endif
