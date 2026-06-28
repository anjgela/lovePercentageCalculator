
data segment
    lmsg db 3,3,3," Love Percentage Calculator ",3,3,3, "$"
    ymsg db "Insert your name: $"
    tmsg db "Insert their name: $"
    again_msg db "Calculate another percentage? (Y/N): $"
    yname db 50 dup('$') ;buffer for ymsg
    tname db 50 dup('$') ;buffer for tmsg
    ylen dw ?
    tlen dw ?
    num db 20 dup(0)
    temp_num db 20 dup(0)
    nlen dw ?
    nhalf dw ?
    
    cr equ 13
    lf equ 10
    crlf db cr, lf, "$"
ends

new_line macro
    push dx
    push ax
    lea dx, crlf
    mov ah, 09h
    int 21h
    pop ax
    pop dx
new_line endm    
            
            

stack segment
    dw 128 dup("STACK")
ends

code segment
    mov ax, data
    mov ds, ax
    xor ax, ax
    
print_love:
    lea dx, lmsg
    mov ah, 09h
    int 21h
    new_line
    new_line
    
input_yname:
    lea dx, ymsg
    mov ah, 09h
    int 21h
    
    mov si, 0
read_yname:
    mov ah, 08h ;read character
    int 21h
    cmp al, 13  ;check if enter has been pressed
    je end_read_yname
    cmp al, 8   ;check if backspace has been pressed
    je bs_yname
    mov yname[si],al ;save character
    inc si
    mov dl, al      ;print character
    mov ah, 02h
    int 21h
    jmp read_yname

bs_yname:
    cmp si, 0   ;prevent crash/erasing prompt if backspace pressed at the beginning
    je read_yname
    dec si  ;decreases array index
    mov ah, 02h
    mov dl, 8   ;move cursor back one space
    int 21h
    mov dl, ' ' ;print blank space to erase character
    int 21h
    mov dl, 8   ;move cursor back again
    int 21h
    jmp read_yname
    
end_read_yname:
    mov yname[si], '$'
    new_line

input_tname:
    lea dx, tmsg
    mov ah, 09h
    int 21h
    
    mov si, 0
read_tname:
    mov ah, 08h ;read character
    int 21h
    cmp al, 13  ;check if enter has been pressed
    je end_read_tname
    cmp al, 8   ;check if backspace has been pressed
    je bs_tname
    mov tname[si], al   ;save character
    inc si
    mov dl, al  ;print character
    mov ah, 02h
    int 21h
    jmp read_tname
    
bs_tname:
    cmp si, 0   ;prevent crash/erasing prompt if backspace pressed at the beginning
    je read_tname
    dec si  ;decreases array index
    mov ah, 02h
    mov dl, 8   ;move cursor back one space
    int 21h
    mov dl, ' ' ;print a space to visually erase the character
    int 21h
    mov dl, 8   ;move cursor back again
    int 21h
    jmp read_tname
    
end_read_tname:  
    mov tname[si], '$'
    new_line
    
    mov si, 0
find_ylenght:    
    cmp yname[si], "$"
    je foundy
    inc si
    jmp find_ylenght    
foundy:
    mov ax, si
    mov ylen, ax
    
    mov si, 0
find_tlenght:
    cmp tname[si], "$"
    je foundt
    inc si
    jmp find_tlenght
foundt:
    mov ax, si
    mov tlen, ax
    
;שששששששששששש

    mov si, 0   ;index (letter to be found in yname)
    mov bx, 0   ;scan name
searchy:
    cmp yname[si], 2Dh      ;check if letter has already been counted
    je nexty                ;if yes, move to next letter 
        
    mov al, yname[si]   ;letter to be found
    mov di, si
    inc di      ;scan yname
    mov cl, 1   ;letter counter
looky:    
    cmp al, yname[di]
    jne updatey
    inc cl
    mov yname[di], 2Dh  ;letter counted -
    
updatey:
    inc di
    cmp di, ylen
    jb looky
    
    mov di, 0   ;look for the letter into tname
lookt:    
    cmp al, tname[di]
    jne updatet
    inc cl
    mov tname[di], 2Dh   ;letter counted -
    
updatet:
    inc di
    cmp di, tlen
    jb lookt
    
    mov num[bx], cl
    inc bx
nexty:
    inc si
    cmp si, ylen
    jb searchy
    
    mov si, 0       ;index (letter to be found in tname)   
searcht:    
    mov di, si      
    inc di          ;scan name
    mov cl, 1       ;letter counter
    
    cmp tname[si], 2Dh  ;check if letter has already been counted
    je update           ;if yes, move to next letter
l11:    
    mov al, tname[si]
    cmp al, tname[di]
    jne l1
    inc cl
    mov tname[di], 2Dh
    
l1:
    inc di
    cmp di, tlen
    jb l11  
        
    mov num[bx], cl
    inc bx
     
update:
    inc si
    cmp si, tlen
    jb searcht       
    
    mov si, 0
display:    
    mov dl, num[si]
    add dl, '0'
    mov ah, 2h
    int 21h
    inc si
    cmp num[si], 0
    jne display
    

    mov nlen, si
    mov ax, nlen
    mov bl, 2
    div bl
    mov nhalf, ax
    
    new_line
    
sum0:  
    xor si, si      ;scan from first element
    mov di, nlen    ;scan from last element
    dec di  
    xor bx, bx  ;index for temp_num
sum:    
    mov al, num[di]
    add al, num[si]
    
    cmp al, 9
    jbe single_digit    ;if > 9 separate the digits
    mov ah, 0
    mov cl, 10
    div cl  ;al=tens, ah=units 
    mov temp_num[bx], al    ;save tens
    inc bx
    mov al, ah  ;move units in al
single_digit:
    mov temp_num[bx], al    ;save unit
    inc bx
    
    inc si
    dec di
    cmp si, di
    jb sum
    ja update_len       ;if si>di complete
    mov al, num[si]              ;if si=di, length was odd -> include the element that has not been updated
    mov temp_num[bx], al
    inc bx
    
update_len:             
    mov nlen, bx
    
    xor si, si
copy_loop:  ;copy temp_num in num
    mov al, temp_num[si]
    mov num[si], al
    inc si
    cmp si, nlen
    jb copy_loop
    
    xor bx, bx
display2:    
    mov dl, num[bx]
    add dl, '0'
    mov ah, 2h
    int 21h
    inc bx
    cmp bx, nlen
    jb display2
    
    cmp nlen, 2         ;if 2 digits
    jbe print_percent   ;print %
    cmp nlen, 3
    ja not_finished     ;if >2, continue calculating
    cmp num[0], 1       ;check if 100
    ja not_finished
    cmp num[1], 0
    ja not_finished
    cmp num[2], 0
    ja not_finished
    jmp print_percent   ;print %
    
not_finished:
    new_line
    jmp sum0

print_percent:
    mov ah, 02h
    mov dl, 37
    int 21h
    new_line
    
ask_restart:
    lea dx, again_msg
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    
    cmp al, 'y'
    je reset_data
    cmp al, 'n'
    jmp exit

reset_data:
    new_line
    mov si, 0
clear_arrays:
    mov num[si], 0
    mov temp_num[si], 0
    inc si
    cmp si, 20
    jb clear_arrays
    
    jmp input_yname
    
    
   
exit:
    mov ah, 4ch
    int 21h
ends