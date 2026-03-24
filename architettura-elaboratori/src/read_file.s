.section .data

invaliderr:
    .ascii "File inserito non valido\n"

invalidlen:
    .long . - invaliderr
fd:
    .long 0

buffer:
    .string ""

.section .text

.global read_file

.type read_file, @function

read_file:
    pushl %ebp                  # salvo ebp su stack in quando andro' a modificare il suo valore
    movl %esp, %ebp             # faccio puntare ebp alla stessa cella di memoria puntata da esp
    movl 8(%ebp), %esi          # salvo in esi l'indirizzo di memoria della prima cella del "vettore", facendo puntare ebp 8 celle piu' in basso

# sezione di codice relativa all'apertura di un file
# eax -> salvo il codice della syscall di apertura file (5)
# ebx -> salvo l'indirizzo di memoria in cui e' memorizzato in nome del file (NOTA: a questo punto del programma ebx contiene gia' l'indirizzo di memoria)
# ecx -> salvo il codice relativo alla modalita' di apertura (lettura -> 0)

open_file:
    movl $5, %eax
    movl $0, %ecx
    int $0x80                   # eseguo la syscall di apertura, in eax viene salvato il file descriptor

    cmpl $0, %eax
    jl exit_read                # se eax vale meno di 0 si e' verificato un errore in apertura, eseguo il salto verso la sezione di codice di uscita dalla funzione

    mov %eax, fd                # salviamo il valore del file descriptor nell'etichetta "fd"

# sezione di codice che esegue la lettura del file carattere per carattere
read_loop:
    movl $3, %eax               # in eax salvo il codice della system call READ
    movl fd, %ebx               # in ebx salvo il valore identificativo del file da cui voglio leggere
    leal buffer, %ecx           # in ecx salvo l'indirizzo di memoria della stringa in cui salvare il valore letto
    movl $1, %edx               # in edx salvo il numero di caratteri che voglio leggere
    int $0x80

    cmp $0, %eax                # verifico la presenza di eventuali errori oppure verifico che il file non sia arrivato alla fine (EOF)
    jle close_file              # in caso di presenza di errori oppure in caso di arrivo alla fine del file viene eseguito il salto alla sezione di chiusura del file

    movb buffer, %bl            # salvo in bl il carattere appena letto

# sezione di codice dedicata al controllo dei caratteri
check_characters:
    cmpb $44, %bl               # se il carattere appena letto corrisponde al carattere ',' ho terminato di salvare il valore di un campo e quindi...
    je scroll_array             # ... scorro l'array alla cella successiva
    cmpb $13, %bl               # se il carattere appena letto corrisponde al carattere '\n' ho terminato di salvare l'ultimo valore di un prodotto e quindi...
    je scroll_array             # ... scorro l'array alla cella successiva
    cmpb $10, %bl               # se il carattere appena letto corrisponde al valore di carriage return...
    je read_loop                # ... torno al read_loop

    # se il carattere non e' numerico (apparte ',' e '\n') salto alla sezione di codice relativa alla gestione di file non valido
    cmpb $48, %bl
    jl invalid_file
    cmpb $57, %bl
    jg invalid_file

# sezione di codice dedicata al salvataggio di ciascun campo su vettore
store_values:
    movl (%esi), %eax           # carico in eax il valore della cella di memoria puntata da esi
    movl $10, %edx              # salvo il valore 10 su edx per fare poi la moltiplicazione per la logica -> num = num * 10 + cifra
    subb $48, %bl               # trasformo il codice ascii della cifra nella cifra vera e propria
    mulb %dl                    # EAX = EAX * 10
    addl %ebx, %eax             # aggiungo ad eax la cifra salvata in ebx
    movl %eax, (%esi)           # salvo il valore nella cella di memoria puntata da esi
    jmp read_loop

# scorrimento del vettore
scroll_array:
    inc %esi                    # faccio puntare esi alla successiva cella di memoria riservata al vettore
    jmp read_loop

close_file:
    movl $6, %eax
    movl %ebx, %ecx
    int $0x80

exit_read:
    popl %ebp                   # riassegno ad ebp il precedente valore

    Ret

# ERRORS
# sezione di codice relativa alla gestione del processo in caso di inserimento di file non valido
invalid_file:
    pushl invalidlen            # salvo su stack la lunghezza della stringa di errore
    pushl $invaliderr           # salvo su stack l'indirizzo di memoria della stringa di errore
    call print_text             # stampo il messaggio di errore
    addl $8, %esp
    jmp error_exit

error_exit:
    movl $6, %eax
    movl %ebx, %ecx
    int $0x80                   # chiudo il file

    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80                   # esco dal programma

