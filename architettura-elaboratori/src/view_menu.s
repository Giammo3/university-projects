.section .data

title:
    .ascii "Menu' pianificatore\n"

title_len:
    .long . - title

menu_item1:
    .ascii "1 - Pianificazione EDF (Earliest Deadline First)\n"

item1_len:
    .long . - menu_item1

menu_item2:
    .ascii "2 - Pianificazione HPF (Highest Priority First)\n"

item2_len:
    .long . - menu_item2

menu_item3:
    .ascii "3 - Esci\n"

item3_len:
    .long . - menu_item3

item_selection:
    .ascii "\nSeleziona una voce: "

selection_len:
    .long . - item_selection

input:
    .ascii "00"

input_error:
    .ascii "E' stata inserita una voce non valida. Inserisci una valore tra 1, 2 o 3\n"

inputerr_len:
    .long . - input_error

edf_title:
    .ascii "\nPianificazione EDF:\n"

edf_len:
    .long . - edf_title

hpf_title:
    .ascii "\nPianificazione HPF:\n"

hpf_len:
    .long . - hpf_title

.section .text

.global view_menu

.type view_menu, @function

view_menu:
    # lettura del titolo del menu'
    pushl title_len
    pushl $title
    call print_text
    addl $8, %esp

    # lettura delle 3 voci
    pushl item1_len
    pushl $menu_item1
    call print_text
    addl $8, %esp

    pushl item2_len
    pushl $menu_item2
    call print_text
    addl $8, %esp

    pushl item3_len
    pushl $menu_item3
    call print_text
    addl $8, %esp

# sezione di codice dedicata alla selezione di una voce

select_item:
    pushl selection_len
    pushl $item_selection
    call print_text
    addl $8, %esp

    movl $3, %eax
    movl $1, %ebx
    leal input, %ecx
    movl $2, %edx

    int $0x80

    movb input, %al
    subb $48, %al
    cmpb $1, %al
    jl selection_error
    cmpb $3, %al
    jg selection_error
    cmpb $3, %al
    je close_menu

    cmpb $2, %al
    je hpf_algorithm

edf_algorithm:
    pushl edf_len
    pushl $edf_title
    call print_text
    addl $8, %esp

    call edf
    call print_algorithm
    jmp select_item

hpf_algorithm:
    pushl hpf_len
    pushl $hpf_title
    call print_text
    addl $8, %esp

    call hpf
    call print_algorithm
    jmp select_item

close_menu:

    ret

selection_error:
    pushl inputerr_len
    pushl $input_error
    call print_text
    addl $8, %esp
    jmp select_item
