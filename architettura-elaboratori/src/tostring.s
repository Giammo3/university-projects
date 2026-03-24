.section .data

strtmp:
    .ascii "000"

.section .text

.global tostring

.type tostring, @function

tostring:
    pushl %ebp
    movl %esp, %ebp
    
    leal strtmp, %edi

    xorl %eax, %eax
    xorl %ebx, %ebx
    movl $10, %ebx
    xorl %ecx, %ecx

    movb 12(%ebp), %al

start_loop:
    xorl %edx, %edx
    divl %ebx
    addb $48, %dl
    movb %dl, (%ecx,%edi,1)
    inc %ecx
    cmpl $0, %eax
    jne start_loop

    xorl %edx, %edx

    movl 8(%ebp), %ebx

reverse:
    xorl %eax, %eax
    movb -1(%ecx,%edi,1), %al
    movb %al, (%edx,%ebx,1)

    inc %edx

    loop reverse

    popl %ebp

    ret
