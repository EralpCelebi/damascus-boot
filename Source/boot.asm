; Damascus Boot Project (2020-2021)
; 
; Maintainer: Eralp Çelebi <eralp.celebi.personal@gmail.com>
; Version: v1.1
; Description: Entry for the bootloader.

[ORG 0x7c00]        ; Basically a memory offset for the program.

jmp boot0

oops:               ; Special memory area for error-codes. Written on errors for debugging.
    dw 0x0000

%include "Source/ata.asm"  ; Needed for loading the second stage.

    ; Type: Label
    ; Description:  This part sets up the environment for future use. Loads the
    ;               second part of the bootloader from the HDD using ATA interrupts.
    ; Arguments:    None

boot0:

    xor ax, ax      ; Sets 'ax' to 0x00.
    
    mov ss, ax      ; Sets the 'ss, ds, es' segments to 'ax' (which is 0x00).
    mov ds, ax      ; As we are using [ORG 0x7c00], we can set our segment
    mov es, ax      ; registers to zero, as we are already offsetted by 0x7c00.
    
    mov sp, 0xf000  ; Sets up a temporary stack at address 0x8000.

    ; Part: Loading boot1
    ; Description:  Using BIOS calls, we will load the second sector of the hard-drive to the address
    ;               0x7e000, which we have our boot1 label at. This way we will have access to more space
    ;               for our bootloader, which can now extend beyond 512 bytes of memory.
    
    xor eax, eax        ; Nullifies the two registers by XOR'ing them with theirselves.
    xor ebx, ebx

    mov eax, 0x7e00     ; Writes 0x7e00 to 'eax'. (The buffer address.)  
    mov ebx, 0x1          ; Writes 0x1 to 'ebx'. (The LBA address.)

    call ata_set_buffer
    
    mov dl, 0x80        ; Writes 0x80 to 'dl'. (The drive number.)

    call ata_read_sector

    jmp boot1           ; Jumps to the second stage.

    ; Part: Signature
    ; Description:  BIOS expects the last word of the first 512 bytes of the binary to
    ;               contain the word "0x55aa". This fills up the remaining space of the 512
    ;               bytes with zeros and adds the signature to the end.

.sign:
    times 510 - ($-$$) db 0
    db 0x55
    db 0xaa

; ================== Sector  Barier ================== ;


    ; Type: Label
    ; Description:  This is the second part of the bootloader that is not automatically
    ;               loaded by the BIOS. It is loaded by 'boot0' using the BIOS ATA interrupts
    ;               at address 0x7e00. 
    ; Arguments:    None.

boot1:
    mov ax, 0xdead
    jmp boot1
