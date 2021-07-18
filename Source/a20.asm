; Copyright (C) 2021  Eralp Çelebi
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

; Name: Damascus Boot Project (2021)
; Author: Çelebi, Eralp <eralp.celebi.personal@gmail.com>
; Version: v0.1
; Description: Functions regarding the A20 line.


; Type: Struct
; Description:  Contains the state of the A20 functions.

a20_flags:
    db 0    ; isChecked, set when 'a20_checks' succeeds.


; Type: Function
; Description:  Checks if the A20 line exists and if so if its
;               activated or not.
; Arguments:    None
; Returns:      Sets the 'a20_checks' flag on success.

a20_checks:
    pushad
    pushf

    mov al, byte [a20_flags]    ; Checks if A20 has already been set before.
    cmp al, 0xff
    je .a20_set

    xor ax, ax                  ; Makes 'ax' equal to 0x0000
    mov es, ax                  ; Loads 'ax' into 'es' (eg. 0x0000:aaaa)

    not ax                      ; Makes 'ax' equal to 0xffff
    mov ds, ax                  ; Loads 'ax' into 'ds' (eg. 0xffff:aaaa)

    mov si, 0x0500              ; 'es':'si' (eg. 0x0000:0x0500)
    mov di, 0x0510              ; 'ds':'di' (eg. 0xffff:0x0510)

    ; Part: A20 line checking.
    ; Description:  If the A20 line is not set, the memory the CPU can access revolves back to
    ;               the start after the 1 MB mark. Using this we can access the same memory
    ;               using a segment offset. If A20 line is not set, we won't overwrite the
    ;               memory.     

    mov [es:si], word 0xdead    ; Writes '0xdead' to '0x0000:0x0500'
    mov [ds:di], word 0xbeef    ; Writes '0xbeef' to '0xffff:0x0510'

    mov ax, word [es:si]        ; Loads 'ax' with the value from '0x0000:0x0500'.
                                ; This will be 0xbeef if the A20 line is not set.

    cmp ax, 0xdead              ; Compares 'ax' to '0xdead'.
    
    je .a20_set

.a20_not_set:
    call a20_setup

.a20_set:
    popf
    popfd

    ret

; Type: Function
; Description:  Sets up the A20 line.
; Arguments:    None
; Returns:      None

a20_setup:
    pushfd
    pushf

    in al, 0x92     ; Fast A20 line. Don't know how it works. Pure magic.
    or al, 2
    out 0x92, al

    popf
    popfd

    ret
