.section .data

.section .text

.global hpf

.type hpf, @function

hpf:
    pushl %ebp
    movl %esp, %ebp
    movl 12(%ebp), %esi

    xorl %edx, %edx

# sezione di codice relativa all'ordinamento dell'array secondo l'algoritmo hpf
hpf_sort:
    movl %esi, %edi
    addl $4, %edi
    movl $9, %ecx
    subl %edx, %ecx

hpf_loop:
    xorl %eax, %eax
    movb 3(%esi), %al
    xorl %ebx, %ebx
    movb 3(%edi), %bl
    cmpb %al, %bl
    je hpf_deadline_sort
    cmpb %al, %bl
    jl hpf_loop_continue

hpf_priority_sort:
    movb %bl, 3(%esi)
    movb %al, 3(%edi)

    movb (%esi), %al
    movb (%edi), %bl
    movb %bl, (%esi)
    movb %al, (%edi)

    movb 1(%esi), %al
    movb 1(%edi), %bl
    movb %bl, 1(%esi)
    movb %al, 1(%edi)

    movb 2(%esi), %al
    movb 2(%edi), %bl
    movb %bl, 2(%esi)
    movb %al, 2(%edi)

    jmp hpf_loop_continue

hpf_deadline_sort:
    movb 2(%esi), %al
    movb 2(%edi), %bl
    cmpb %al, %bl
    jge hpf_loop_continue

    movb %bl, 2(%esi)
    movb %al, 2(%edi)

    movb (%esi), %al
    movb (%edi), %bl
    movb %bl, (%esi)
    movb %al, (%edi)

    movb 1(%esi), %al
    movb 1(%edi), %bl
    movb %bl, 1(%esi)
    movb %al, 1(%edi)

    movb 3(%esi), %al
    movb 3(%edi), %bl
    movb %bl, 3(%esi)
    movb %al, 3(%edi)

hpf_loop_continue:
    addl $4, %edi
    loop hpf_loop

    addl $4, %esi
    inc %edx
    cmpl $9, %edx
    jl hpf_sort

    popl %ebp

    ret

