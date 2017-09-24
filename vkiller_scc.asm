; -----------------------------------------------------------
; Code for hooking in calls to the nemesis 3 SCC player

        output  vkiller_patch00038.bin
        org     04038h

        call    music_update_shim



        output  vkiller_patch010b2.bin
        org     050b2h

        pop     af
        ld      e, a  ; save song index for later
        push    af
        nop
        call    music_start_shim
        nop
        nop
        nop



        output vkiller_patch013bf.bin
        org     053bfh  ; space: 18 bytes

        db      018h  ; jr 05383h
        db      0c2h
music_update_shim:
        ld      a, 16
        ld      (07000h), a
        call    music_update
        ld      (07000h),a
        ret



        output vkiller_patch0139b.bin
        org     0539bh  ; space: 12 bytes

        db      018h  ; jr 0539bh
        db      0ech
music_start_shim:
        ld      a, 16
        ld      (07000h), a
        call    music_start
        ld      (hl), a
        ret


; -----------------------------------------------------------
; The code below lives in nemesis 3 SCC player mapper banks

        output vkiller_patch21f00.bin
        org     07f00h

write_psg:
        cp      a, 7
        jr      nz, not_register_seven
        ; combine vkiller player bits with our own bits
        and     011011011b
        push    de
        push    hl
        ld      d, a
        ld      hl, 0c097h
        ld      a, (hl)
        and     011100100b
        or      d
        ld      (hl), a  ; write combined bits back to vkiller state
        pop     hl
        pop     de
not_register_seven:
        out     (0A0h), a  ; set register
        push    af
        ld      a, e
        out     (0A1h), a  ; write value
        pop     af
        ret


music_start:
        ; if we are starting a sound effect, ignore
        ld      a, e
        and     0x80
        jp      z,music_start_skip

        di
        ; swap RAM into 0000-3fff
        ld      c, 0a8h
        in      b, (c)
        ld      a, b
        or      03h
        out     (c), a

        ; get subslot from page 3 (c000-ffff) and apply to page 0 (0000-3fff)
        push    bc
        push    hl
        ld      hl, 0ffffh
        ld      a, (hl)
        cpl
        push    af
        ld      b, a
        and     011000000b
        rlca    
        rlca
        ld      c, a
        ld      a, b
        and     011111100b
        or      c
        ld      (hl), a

        ; map music-player ROM pages into 8000-bfff
        ld      a, 17
        ld      (09000h), a
        ld      a, 18
        ld      (0b000h), a

        ld      a, (02000h)
        or      a
        jr      z, skip_memory_clean

        push    bc
        push    de
        ld      hl, 02000h
        ld      de, 02001h
        ld      bc, 00300h
        ld      (hl), 0
        ldir
        pop     de
        pop     bc

        ld      hl, 00038h
        ld      a, 076h
        ld      (hl), a

skip_memory_clean:

        push bc
        ; 6 = track 0
        ld      a,e
        and     07fh
        inc     a
        inc     a
        inc     a
        inc     a
        inc     a
        inc     a
        call    06003h  ; nemesis 3 song start function
        pop     bc

        pop     af
        ld      (0ffffh), a
        pop     hl
        pop     bc

        ; restore BIOS ROM       
        out     (c), b

music_start_skip:

        di
        ld      a, 14
        ld      (09000h), a
        ld      (0f0f2h), a
        ld      a, 15
        ld      (0b000h), a
        ld      (0f0f3h), a
        ld      a, (0f0f1h)
        ld      hl, 07000h
        ret

music_update:
        push    bc
        push    de
        push    hl
        push    ix
        push    iy

        ; map RAM into bank 0000-3fff
        ld      c, 0a8h
        in      b, (c)
        push    bc
        ld      a, b
        or      03h
        out     (c), a

        ; get subslot from page 3 (c000-ffff) and apply to page 0 (0000-3fff)
        ld      hl, 0ffffh
        ld      a, (hl)
        cpl
        push    af
        ld      b, a
        and     011000000b
        rlca    
        rlca
        ld      c, a
        ld      a, b
        and     011111100b
        or      c
        ld      (hl), a

        ld      a, 17
        ld      (09000h), a
        ld      a, 18
        ld      (0b000h), a

        call    06006h  ; nemesis 3 song update function

        pop     af
        ld      (0ffffh), a

        ; restore ROM
        pop     bc
        out     (c), b
ram_not_initialised:
        ld      a, 14
        ld      (09000h), a
        ld      a, 15
        ld      (0b000h), a
        ld      a, (0f0f1h)

        pop     iy
        pop     ix
        pop     hl
        pop     de
        pop     bc
        ret

end_of_program:
        assert end_of_program < 0c000h


; -----------------------------------------------------------
; Disable SCC player PSG channel used for vkiller SFX

        ;output vkiller_patch203ad.bin
        ;org     063adh
        ;nop
        ;nop
        ;nop

        ;output vkiller_patch203b9.bin
        ;org     063b9h
        ;nop
        ;nop
        ;nop

        ;output vkiller_patch203c52.bin
        ;org     063c52h
        ;nop
        ;nop
        ;nop



;--------------------------------------------------
; disable vampire killer PSG music-only channels

        output vkiller_patch1c9aa.bin  ; doesnt actually work!
        nop
        nop
        nop

        output vkiller_patch1c9b3.bin  ; doesnt actually work!
        nop
        nop
        nop

        ;output vkiller_patch1c9bc.bin
        ;nop
        ;nop
        ;nop


;------------------------------------------------
; stop vkiller music playing 

        output vkiller_patch010cc.bin
        jp      0513fh
