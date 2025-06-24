.Model small
.Stack 100h
.Data
    ; bien 
    ball_x dw 40
    ball_y dw 12
    ball_dx dw 1
    ball_dy dw 1    
    paddle_x dw 35
    paddle_y dw 23
    paddle_width dw 12
    game_active db 0
    last_hit db 0   
    heart db 03h
    
    ; menu
    tb1 db 'RAPID BALL (PONG)$'
    tb db 'This game by: NHOM 12$'
    tb2 db 'Move the yellow bar by pressing$' 
    tb3 db 'the keys <-, -> to catch the ball$' 
    tb4 db '<-: move left$'
    tb5 db '->: move right$'
    tb6 db 'You have 2 lives$'   
    tb7 db 'The speed of the ball will change when the player loses a life'
    tb8 db 'Press any key to start...$' 
    
    ;msg  
    msg_start db 'RAPID BALL - Press SPACE to start$'
    msg_pause db 'PAUSED - Press SPACE to continue$'
    msg_gameover db 'GAME OVER$'
    msg_restart db 'Press any key to restart$'  
    
    ;score 
    score dw 0
    tb_score db 'Score:$'
    
    ;live
    lives db 2
    tb_live db 'Lives:$'
    
.Code
Main proc
    start:
        mov ax, @data 
        mov ds, ax
        
        ; ghi du lieu truc tiep vao bo nho video
        ; de hien ky tu/ mau sac   
        mov ax, 0b800h
        mov es, ax      
        
        call menu_game
        call screen_game  
        call draw_ball 
        call draw_paddle
    
    check_game:                                
        mov ah, 1                 
        int 16h                     
        jz no_key                    
        
        mov ah, 00h
        int 16h
        
        cmp ah, 4Bh 
        ; Left arrow
        je move_left
        cmp ah, 4Dh 
        ; Right arrow
        je move_right
        cmp al, 20h 
        ; Space
        je pause_game
        cmp al, 1Bh 
        ; ESC
        je exit_game
        jmp no_key      
      
    move_left:
        cmp byte ptr [game_active], 0
        je no_key  
        
        cmp word ptr [paddle_x], 1
        jle no_key
        sub word ptr [paddle_x], 2
        call draw_paddle
        jmp no_key
        
    move_right:
        cmp byte ptr [game_active], 0
        je no_key
        
        mov ax, [paddle_x]
        add ax, [paddle_width]
        cmp ax, 79
        jge no_key
        add word ptr [paddle_x], 2
        call draw_paddle
        jmp no_key  
        
    pause_game:
        cmp byte ptr [game_active], 0
        je start_game
        xor byte ptr [game_active], 1
        jnz no_key
        call pause_message
        jmp no_key
        
    start_game:
        cmp byte ptr [lives], 0
        jne continute_game
        mov byte ptr [lives], 2
        call clear_messages
        
    continute_game:
        mov byte ptr [game_active], 1
        mov byte ptr [last_hit], 0
        call clear_messages
        jmp no_key
        
    no_key:
        cmp byte ptr [game_active], 0
        je check_game
        
        call move_ball     
        
    delay_game:
        mov cx, 0001h
        mov dx, 0000h
        mov ah, 86h
        int 15h
        
        jmp check_game
    
    exit_game:
        mov ax, 0003h
        int 10h
        mov ax, 4C00h
        int 21h
        
    menu_game proc  
        ; che do hien thi 
        mov ah,0      
        ; che do van ban
        mov al,3
        int 10h
        
        ; chuc nang cuon man hinh
        mov ah,6 
        ; cuon toan bo man hinh
        mov al,0 
        mov bh,0Fh 
        
        call border 

        ;loi dan
        mov di, 704       
        lea si, tb1       
        mov cx, 17         
        lop1:
        movsb               
        inc di              
        loop lop1     
        
        mov di,1010
        lea si,tb2
        mov cx,31
        lop2:
        movsb 
        inc di
        loop lop2 
        
        mov di,1330
        lea si,tb3
        mov cx,33
        lop3:
        movsb 
        inc di
        loop lop3
        
        mov di,1670
        lea si,tb4
        mov cx,13
        lop4:
        movsb 
        inc di
        loop lop4
        
        mov di,1990
        lea si,tb5
        mov cx,14
        lop5:
        movsb 
        inc di
        loop lop5
        
        mov di,2304
        lea si,tb6
        mov cx,16
        lop6:
        movsb 
        inc di
        loop lop6
        
        mov di,2580
        lea si,tb7
        mov cx,62
        lop7:
        movsb 
        inc di
        loop lop7 
        
        mov di,2936
        lea si,tb8
        mov cx,25
        lop8:
        movsb 
        inc di
        loop lop8
        
        mov di,3260
        lea si,tb
        mov cx,21
        loptb:
        movsb 
        inc di
        loop loptb
        
        mov ah,7
        int 21h
         
        ret
    menu_game endp 
    
    border proc     
        mov ah,6
        mov al,0 
        mov bh,0ffh  
        
        mov ch, 0 
        ;dong bat dau
        mov cl, 0 
        ;cot bat dau
        mov dh, 0 
        ;dong kthuc
        mov dl, 80
        ;cot kthuc
        int 10h
      
        mov ch, 0
        mov cl, 0
        mov dh, 24
        mov dl, 0
        int 10h
       
        mov ch, 24
        mov cl, 0
        mov dh, 24
        mov dl, 79
        int 10h
        
        mov ch, 1
        mov cl, 79
        mov dh, 24
        mov dl, 79
        int 10h
        
        ret
    border endp 
    
    screen_game proc 
        mov ax, 3
        int 10h
        
        mov ah,6
        mov al,0 
        mov bh,0Eh 
        
        ; top border
        mov dx, 0000h
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 205
        mov bl, 0Fh
        mov cx, 80
        mov ah, 9
        int 10h
        
        call change_live_score
         
        ; msg  
        mov di, 1650
        lea si,msg_start
        mov cx,33
        lopst:
        movsb 
        inc di
        loop lopst
        
        ret
    screen_game endp    
    
    draw_paddle proc
        ; xoa hang chua thanh do
        mov dh, byte ptr [paddle_y]
        mov dl, 0
        mov bh, 0 
        ;trang hien thi 0
        mov ah, 2
        int 10h
        
        mov al, ' '
        mov bl, 0Fh
        mov cx, 80
        mov ah, 9
        int 10h
        
        ; ve thanh do
        mov dh, byte ptr [paddle_y]
        mov dl, byte ptr [paddle_x]
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 219
        mov bl, 0Eh
        mov cx, [paddle_width]
        mov ah, 9
        int 10h
        ret
    draw_paddle endp
    
    draw_ball proc 
        mov dh, byte ptr [ball_y]
        mov dl, byte ptr [ball_x]
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 219
        mov bl, 0Ah
        mov cx, 1
        mov ah, 9
        int 10h
        ret
    draw_ball endp
    
    move_ball proc 
        ; xoa bong  cu
        mov dh, byte ptr [ball_y]
        mov dl, byte ptr [ball_x]
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, ' '
        mov bl, 0
        mov cx, 1  
        ;kich thuoc bong
        mov ah, 9
        int 10h
        
        ; cap nhat toa do
        mov ax, [ball_x]
        add ax, [ball_dx]
        mov [ball_x], ax
        
        mov ax, [ball_y]
        add ax, [ball_dy]
        mov [ball_y], ax
        
        ; va cham voi tuong
        cmp word ptr [ball_x], 1
        jle bounce_x
        cmp word ptr [ball_x], 78
        jge bounce_x
        
        cmp word ptr [ball_y], 2
        jle bounce_y
        
        ; cham vao thanh do
        mov ax, [ball_y] 
        inc ax
        cmp ax, [paddle_y]
        jne check_miss
        
        mov ax, [ball_x]
        cmp ax, [paddle_x]
        jl check_miss  
        
        mov bx, [paddle_x]
        add bx, [paddle_width]
        cmp ax, bx
        jg check_miss
        
        neg word ptr [ball_dy] 
        ; dao chieu
        
        ; tang diem khi bong cham paddle
        add word ptr [score], 10
        call change_live_score
        
        mov byte ptr [last_hit], 1
        jmp draw_new_ball
        
    bounce_x:          
        neg word ptr [ball_dx]
        mov byte ptr [last_hit], 0
        jmp draw_new_ball
        
    bounce_y:
        neg word ptr [ball_dy]
        mov byte ptr [last_hit], 0
        jmp draw_new_ball
        
    check_miss:
        mov byte ptr [last_hit], 0
        cmp word ptr [ball_y], 24
        jl draw_new_ball
        
        dec byte ptr [lives]
        call change_live_score 
        
        cmp byte ptr [lives], 0
        je game_over
        
        ; Reset ball
        mov word ptr [ball_x], 40
        mov word ptr [ball_y], 12
        mov word ptr [ball_dx], 2
        mov word ptr [ball_dy], 2 
        neg word ptr [ball_dy]   
        mov word ptr paddle_width, 15
        mov word ptr [paddle_x], 35
        mov byte ptr [game_active], 0   
        call pause_message
        call draw_paddle
        jmp skip_draw
        
    game_over:
        mov byte ptr [game_active], 0
        call restart_message
        jmp skip_draw
        
    draw_new_ball:
        call draw_ball 
    skip_draw:    
        
        ret
    move_ball endp
    
    change_live_score proc                  
        ;live 
        mov di,132
        lea si,tb_live
        mov cx,7
        lopl:
        movsb 
        inc di
        loop lopl
        
        ;dua con tro toi vi tri moi
        mov ah, 2    
        mov bh, 0      
        mov dh, 0     
        mov dl, 73   
        int 10h
        
        ; hien trai tim
        mov bl, 0Ch ; mau do
        mov cx, 2
        mov al, [heart]
        
        draw_hearts:
        push cx
        dec cx
        cmp cl, [lives]
        jge empty_heart
        mov ah, 9
        mov cx, 1
        int 10h
        jmp next_heart
        
        empty_heart:
        push ax
        mov al, ' '
        mov ah, 09h
        mov cx, 1
        int 10h
        pop ax
        
        next_heart:
        ; di chuyen con tro sang trai
        mov ah, 03h
        int 10h
        dec dl
        mov ah, 02h
        int 10h
        
        pop cx
        loop draw_hearts 
        
        ;score    
        mov di,6
        lea si,tb_score
        mov cx,6
        lopescore:
        movsb 
        inc di
        loop lopescore

        mov ah, 2    
        mov bh, 0      
        mov dh, 0     
        mov dl, 9   
        int 10h
        
        mov ax, [score]
        call print_score
    
        ret
    change_live_score endp     
    
    print_score proc 
            ; in diem
            push ax
            push bx
            push cx
            push dx
            mov bx, 10 
            xor cx, cx 
    
        convert:
            xor dx, dx
            div bx
            push dx
            inc cx
            test ax, ax
            jnz convert
    
        print_loop:
            pop dx
            add dl, '0'
            mov ah, 2
            int 21h
            loop print_loop
        
            pop dx
            pop cx
            pop bx
            pop ax
        ret
    print_score endp
    
    pause_message proc 
        mov ah,6
        mov al,0 
        mov bh,0Fh  
        
        mov di,1650
        lea si,msg_pause
        mov cx,32
        lopps:
        movsb 
        inc di
        loop lopps 
    
        ret
    pause_message endp
    
    restart_message proc        
        call clearall  
        call border  
        
        mov ah,6
        mov al,0 
        mov bh,0Fh 
         
        mov di,1670
        lea si,msg_gameover
        mov cx,9
        lopend:
        movsb 
        inc di
        loop lopend
        
        mov di,1990
        lea si,tb_score
        mov cx,6
        lopesc:
        movsb 
        inc di
        loop lopesc
        
        mov ah, 2    
        mov bh, 0      
        mov dh, 12     
        mov dl, 42   
        int 10h
        
        mov ax, [score]
        call print_score 
        
        mov di,2300
        lea si,msg_restart
        mov cx,25
        loprs:
        movsb 
        inc di
        loop loprs

        ; quay lai ctr
        mov ax, 1 
        int 16h          
        call clearall 
        call re_var
        jmp start        
        ret
    restart_message endp  
    
    re_var proc
        mov word ptr [ball_x], 40
        mov word ptr [ball_y], 12
        mov word ptr [ball_dx], 1
        mov word ptr [ball_dy], 1   
        mov word ptr [paddle_width], 12
        mov word ptr [paddle_x], 35
        mov byte ptr [game_active], 0    
        mov byte ptr [score], 0 
        mov byte ptr [lives], 2  
        mov byte ptr [last_hit], 0 
        
        ret
    re_var endp
    
    clear_messages proc 
        mov cx, 2
        mov dh, 10
    clear_loop:
        push cx
        push dx
        
        mov dl, 0
        mov bh, 0
        mov ah, 02h
        int 10h
        
        mov al, ' '
        mov bl, 0Fh
        mov cx, 80
        mov ah, 09h
        int 10h
        
        pop dx
        inc dh
        pop cx
        loop clear_loop
        ret
    clear_messages endp  
    
    clearall proc
    
        xor cx,cx
        mov dh,24
        mov dl,79
        mov bh,7
        mov ax,700h
        int 10h 
        
        ret
    clearall endp
    
END 
                       
                        