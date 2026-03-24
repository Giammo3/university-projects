.section .data

msg_error:
    .ascii "Parametro non inserito\n"

errorlen:
    .long . - msg_error

emptyerr:
    .ascii "Il file e' vuoto, inesistente o non presenta prodotti\n"

emptylen:
    .long . - emptyerr

products:
    .long 0,0,0,0,0,0,0,0,0,0                     # riservo 10 spazi di memoria da 4 byte (array-tipo)

.section .text
    .global _start

_start:
    popl %ebx           # rimuovo dallo stack il numero di paramteri passati
    popl %ebx           # rimuovo dallo stack l'indirizzo di memoria in cui e' memorizzato il nome del programma
    popl %ebx           # salvo in ebx l'indirizzo di memoria in cui e' memorizzato il parametro corrispondente al nome del file da leggere
    cmpl $0, %ebx
    je parameter_error

    pushl $products

    call read_file      # chiamo la funzione read_file

    jmp check_array

print:

    call view_menu

# chiamata della system call di uscita (eax -> salvo il codice della syscall (1), ebx -> salvo il codice di uscita (0))
end:
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80


# -------------------- ERRORS -------------------------------------

parameter_error:
    pushl errorlen
    pushl $msg_error
    call print_text
    addl $8, %esp
    jmp end

check_array:
    leal products, %esi
    xorl %eax, %eax
    movb (%esi), %al
    cmpb $0, %al
    je empty_array

    jmp print

empty_array:
    pushl emptylen
    pushl $emptyerr
    call print_text             # stampo il messaggio di errore relativo all'inserimento di file vuoto o file privo di prodotti
    addl $8, %esp
    jmp end
