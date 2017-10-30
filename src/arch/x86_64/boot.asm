global start

section .text
bits 32
start:
    mov esp, stack_top ; Initialize stack pointer

    call initialize_page_tables
    call enable_paging

    mov dword [0xb8000], 0x2f4b2f4f
    hlt


initialize_page_tables:
    ; mapping first p4 entry to the p3 table
    mov eax, p3_table
    or eax, 0b11
    mov [p4_table], eax

    ; map 1st p3 to p2
    mov eax, p2_table
    or eax, 0b11
    mov [p3_table], eax

    mov ecx, 0

.map_p2_table:
    mov eax, 0x200000
    mul ecx
    or eax, 0b10000011
    mov [p2_table + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ret

enable_paging:
    mov eax, p4_table
    mov cr3, eax

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret

error:
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], aL
    hlt

section .bss
align 4096
p4_table: ; Page-Map Table
    resb 4096
p3_table: ; Page-Directory Pointer Table
    resb 4096
p2_table: ; Page-Directory Table
    resb 4096
stack_bottom:
    resb 64
stack_top:
