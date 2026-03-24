.section .data

.section .text

.global edf

.type edf, @function

edf:
    pushl %ebp
    movl %esp, %ebp
    movl 12(%ebp), %esi

    xorl %edx, %edx

# sezione di codice relativa all'ordinamento dell'array secondo l'algoritmo edf
edf_sort:
    movl %esi, %edi
    addl $4, %edi
    movl $9, %ecx
    subl %edx, %ecx

edf_loop:
    xorl %eax, %eax
    movb 2(%esi), %al
    xorl %ebx, %ebx
    movb 2(%edi), %bl
    cmpb $0, %al
    je edf_end
    cmpb $0, %bl
    je edf_loop_continue
    cmpb %al, %bl
    je edf_priority_sort
    cmpb %al, %bl
    jg edf_loop_continue

edf_deadline_sort:
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

    jmp edf_loop_continue

edf_priority_sort:
    movb 3(%esi), %al
    movb 3(%edi), %bl
    cmpb %al, %bl
    jle edf_loop_continue

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

edf_loop_continue:
    addl $4, %edi
    loop edf_loop

    addl $4, %esi
    inc %edx
    cmpl $9, %edx
    jl edf_sort

edf_end:
    popl %ebp

    Ret
