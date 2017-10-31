global long_mode_start

section .text
bits 64
long_mode_start:

    extern rust_main
    call rust_main

    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    hlt
