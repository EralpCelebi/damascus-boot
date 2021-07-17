; Copyright (C) 2021 Eralp Çelebi
; Author: Çelebi, Eralp <eralp.celebi.personal@gmail.com>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; Name: Damascus Boot Project (2020-2021)
; Author: Çelebi, Eralp <eralp.celebi.personal@gmail.com>
; Version: v0.1
; Description: Code for handling ATA using BIOS interrupts.

    ; Type: Struct
    ; Description: Disk Address Packet. Used for reading/writing sectors.

ata_dap:
    db 16       ; Size of the packet, 16-bytes for 48-bit LBA.
    db 0        ; Always zero.
    dw 1        ; Number of sectors to read/write
    dw 0x7e00   ; Memory offset. (Defaults to the position of the second stage bootloader.)
    dw 0x0000   ; Segment offset.
    dd 0x0      ; Lower 32-bits of LBA.
    dd 0x0      ; Upper 16-bits of LBA.


    ; Type: Struct
    ; Description: Variables concerning the ATA 'class'.

ata_flags:
    db 0    ; isChecked, set when the 'ata_checks' function succeeds.


    ; Type: Function
    ; Description:  Checks necessary for the ATA system.
    ; Arguments:    'dl' -> Drive to check.
    ; Returns:      Writes 0x0001 to 'oops' on error.

ata_checks:
    pushad
    pushf

    ; Part: Already checked?
    ; Description: If the flag in 'ata_flags' is checked, exit.

    mov al, byte [ata_flags]
    test al, 0xff
    jz .success
    
    ; Part: LBA check.
    ; Description:  Uses 'int 0x13' to check if the drive numbered 'dl' supports LBA.
    ;               If the drive does not suppot LBA, this function will exit with an error.
    mov ah, 0x41
    mov bx, 0x55aa
    
    int 0x13

    jc  .error
    jmp .success

.error:
    mov [oops], word 0x0001 ; Writes 0x0001 to 'oops'
    jmp ata_checks.end

.success:
    mov [ata_flags], byte 0xff

.end:
    popf
    popad
    
    ret


    ; Type: Function
    ; Description:  Edits the DAP's buffer address. 
    ; Arguments:    'eax' -> Pointer to the buffer. (eg. 0x0000:0x7e00)
    ;               'ebx' -> Lower 32-bits of the LBA address.
    ; Returns:      None
    ;
    ; Notes:        This function does not use the upper 16-bits of the LBA address.
    ;               This means you won't be able to read the fully supported 48-bit addresses of LBA
    ;               addressing. Wasn't planning on using it so didnt implement it.

ata_set_buffer:
    pushad
    pushf

    mov [ata_dap + 4], eax ; Writes 'eax' to the buffer section of the DAP.
    mov [ata_dap + 8], ebx ; Writes 'ebx' to the lower LBA section of the DAP.

    popf
    popad

    ret


    ; Type: Function
    ; Description:  Reads a sector from an hard-drive.
    ; Arguments:    'dl' -> Specifies the drive number.
    ; Returns:      None

ata_read_sector:
    pushad
    pushf

    call ata_checks     ; Check if LBA is supported.

    ; Part: 'ah=0x42' 'int 0x13'
    ; Description: Calls the BIOS routine for reading from a drive to a buffer.
    
    mov si, ata_dap     ; Set 'si' to the address of the DAP.
    mov ah, 0x42

    int 0x13            ; Interrupt.

    popf
    popad

    ret

; TODO: Add an ata_write_function as a reference.
