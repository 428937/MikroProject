org 100h

basla:
    mov ah, 09h
    mov dx, offset mesaj_giris
    int 21h

yeni_tur:
secim_dongusu:
    ; Rastgele harf uretme (Sistem saati kullanilir)
    mov ah, 00h
    int 1Ah
    mov ax, dx
    xor dx, dx
    mov cx, 8         ; Harf havuzu genisligi (8 = a'dan h'ye)
    div cx
    add dl, 97        ; 'a' karakterinin ASCII karsiligi
    
    ; Arka arkaya ayni harf gelmesini engelle
    cmp dl, [son_harf]
    je secim_dongusu
    mov [son_harf], dl
    mov [hedef_harf], dl

    ; Ekrani temizlemeden satir basina don ve bilgileri yazdir
    mov ah, 02h
    mov dl, 13        ; Satir basi
    int 21h
    
    ; Hedef harfi yaz
    mov dl, [hedef_harf]
    int 21h
    
    ; Guncel Kombo Yazisi
    mov ah, 09h
    mov dx, offset mesaj_kombo
    int 21h
    mov ax, [kombo]
    call sayi_yazdir

    ; En Iyi Skor Yazisi
    mov ah, 09h
    mov dx, offset mesaj_best
    int 21h
    mov ax, [en_iyi]
    call sayi_yazdir

    ; Zaman sinirini belirle (BIOS Tick ile olc, 18 tick = 1 sn ediyo yaklasik)
    mov ah, 00h
    int 1Ah
    mov bx, dx
    add bx, [bekleme_suresi]

input_dongusu:
    ; Zaman doldu mu kontrol et
    mov ah, 00h
    int 1Ah
    cmp dx, bx
    jae hata_zaman_asimi

    ; Klavyeden tus geldi mi bak
    mov ah, 01h
    int 16h
    jnz tus_geldi
    jmp input_dongusu

tus_geldi:
    mov ah, 00h
    int 16h           ; Basilan tusu oku (AL'ye atar)

    ;Backspace (8) basildiysa oyunu kapat
    cmp al, 8
    je oyun_sonu

    ; Harf kontrolu
    cmp al, [hedef_harf]
    je basarili_hamle
    jmp hata_yanlis_tus

basarili_hamle:
    inc [kombo]
    mov ax, [kombo]
    cmp ax, [en_iyi]
    jbe hizi_ayarla   ; Eger kombo en iyiden kucukse atla
    mov [en_iyi], ax  ; Yeni en iyi skoru kaydet

hizi_ayarla:
    ; Minimum hiz siniri (18 tick = 1 saniye)
    cmp [bekleme_suresi], 18
    jbe turu_bitir
    
    ; Her basarili tusta sure 0.5 sn (~9 tick) azaliyo
    sub [bekleme_suresi], 9
turu_bitir:
    jmp yeni_tur

hata_zaman_asimi:
    mov ah, 09h
    mov dx, offset mesaj_sure_bitti
    int 21h
    jmp skor_sifirla

hata_yanlis_tus:
    mov ah, 09h
    mov dx, offset mesaj_yanlis
    int 21h
    jmp skor_sifirla

skor_sifirla:
    mov [kombo], 0
    mov [bekleme_suresi], 108 ; Baslangic suresi (108 tick = 6 saniye)
    jmp yeni_tur

oyun_sonu:
    mov ah, 4Ch       ; DOS cikis komutu
    int 21h

sayi_yazdir proc
    push ax
    push bx
    push cx
    push dx
    mov bx, 10
    mov cx, 0
parcala:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne parcala
yazdir:
    pop dx
    add dl, 48
    mov ah, 02h
    int 21h
    loop yazdir
    pop dx
    pop cx
    pop bx
    pop ax
    ret
sayi_yazdir endp

mesaj_giris      db 'Ritim Oyunu: Tuslara basin! (Cikis: Backspace)', 13, 10, '$'
mesaj_kombo      db '  Kombo sayaci: ', '$'
mesaj_best       db '     , En Iyi: ', '$'
mesaj_sure_bitti db 13, 10, 'Sure Doldu! Kombo Sifirlandi.', 13, 10, '$'
mesaj_yanlis     db 13, 10, 'Yanlis Tus! Kombo Sifirlandi.', 13, 10, '$'

hedef_harf       db 0
son_harf         db 0
kombo            dw 0
en_iyi           dw 0  ; En iyi skoru tutan degisken
bekleme_suresi   dw 108 ; Baslangic suresine don (6 saniye = 108 tick)

end
