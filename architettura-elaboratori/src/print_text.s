.section .data

.section .text

.global print_text

.type print_text, @function

print_text:
    pushl %ebp
    movl %esp, %ebp
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx

    xorl %edx, %edx

    movl $4, %eax
    movl $1, %ebx
    movl 8(%ebp), %ecx
    movb 12(%ebp), %dl
    int $0x80

    popl %edx
    popl %ecx
    popl %ebx
    popl %eax

    popl %ebp

    Ret
