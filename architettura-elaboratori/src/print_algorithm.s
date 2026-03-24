.section .data

numstr:
    .ascii "0000"

conclusionstr:
    .ascii "Conclusione: "

conclusionlen:
    .long . - conclusionstr

penaltystr:
    .ascii "Penalty: "

penaltylen:
.long . - penaltystr

conclusion:
    .byte 0

penalty:
    .byte 0

.section .text

.global print_algorithm

.type print_algorithm, @function

print_algorithm:
    pushl %ebp
    movl %esp, %ebp
    movl 12(%ebp), %esi

    movl $10, %ecx

print_info:
    pushl %ecx

    xorl %eax, %eax

    movb (%esi), %al

    cmpb $0, %al
    je loop_continue

    pushl %eax
    pushl $numstr
    call tostring
    addl $8, %esp

    movb $58, (%edx,%ebx,1)
    incl %edx

    pushl %edx
    pushl $numstr
    call print_text
    addl $8, %esp

    xorl %eax, %eax
    movb conclusion, %al

    pushl %eax
    pushl $numstr
    call tostring
    addl $8, %esp

    movb $10, (%edx,%ebx,1)
    incl %edx

    pushl %edx
    pushl $numstr
    call print_text
    addl $8, %esp

    xorl %ecx, %ecx

    xorl %eax, %eax
    movb 1(%esi), %al
    addb %al, conclusion

penalty_calc:
    xorl %ebx, %ebx
    movb 2(%esi), %bl
    movb conclusion, %al

    cmpb %bl, %al
    jle loop_continue
    subl %ebx, %eax
    xorl %ebx, %ebx
    movb 3(%esi), %bl
    mulb %bl
    addb %al, penalty

loop_continue:  
    addl $4, %esi
    popl %ecx
    dec %ecx

    jg print_info

print_conclusion:
    pushl conclusionlen
    pushl $conclusionstr
    call print_text
    addl $8, %esp

    xorl %eax, %eax
    movb conclusion, %al

    pushl %eax
    pushl $numstr
    call tostring
    addl $8, %esp

    movb $10, (%edx,%ebx,1)
    incl %edx

    pushl %edx
    pushl $numstr
    call print_text
    addl $8, %esp

print_penalty:
    pushl penaltylen
    pushl $penaltystr
    call print_text
    addl $8, %esp

    xorl %eax, %eax
    movb penalty, %al

    pushl %eax
    pushl $numstr
    call tostring
    addl $8, %esp

    movb $10, (%edx,%ebx,1)
    incl %edx

    pushl %edx
    pushl $numstr
    call print_text
    addl $8, %esp

    popl %ebp

    movl $0, conclusion
    movl $0, penalty

    ret
