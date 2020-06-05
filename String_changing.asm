include console.inc

COMMENT *
УСЛОВИЕ:  
Текст оканчивается заглавной латинской буквой, которая больше не встречается в тексте
1) Заменить каждую заглавную латинскую букву на цифру, числовое значение которой равно величине N mod 10 (1 <= N <= 26)
2) Оставить в тексте только те литеры, которые входят в него ровно один раз
*
N equ 100
M equ 256
.data 
Str db N dup (?)
Y db M dup (0)   ; вспомогательный массив для правила 2
.code
;=================================== ОСНОВНАЯ ПРОГРАММА
Start:
; проверка сохранности регистров                 
   mov eax, 1
   mov ebx, 2
   mov ecx, 3
   mov edx, 4
   mov esi, 5
   mov edi, 6
   push ebp
   push eax
   push ebx
   push ecx
   push edx
   push esi
   push edi
   ;mov ebp, esp
   

   outstr "Enter your text with '.' (under 100 elements):"
   mov edi, offset Str   ; адрес строки
   mov esi, edi          ; еще раз сохраню адрес строки, чтобы сразу использовать его в Output
   mov ebx, edi          ; и еще раз для Check
   mov ecx, N
   call Input 
   newline
   outstr "Text is "
   call Output                     
   newline

   dec edi               ; последний символ в строке - точка. Поэтому вычтем 1, чтобы получить последнюю букву
   mov esi, edi
   call Check
   
   or al, al
   jnz m1
   m0:                  ; al = 0 => второе правило
      mov esi, offset Str
      mov ebx, offset Y 
      mov ecx, N
      push ebx
      push ecx
      push esi 
      call Second               
      jmp final
   m1:                 ; al = 1 => первое правило
      mov esi, offset Str
      mov ecx, N 
      push ecx
      push esi 
      call First              
   final:
      outstr "Modified text is "
      mov esi, offset Str
      mov ecx, N
      call Output                
      
      pop edi                   
      pop esi
      pop edx
      pop ecx
      pop ebx
      pop eax
      pop ebp
      outwordln edi
      outwordln esi
      outwordln edx
      outwordln ecx
      outwordln ebx
      outwordln eax
      newline
      
   MsgBox "End of program","Repeat?",MB_YESNO+MB_ICONQUESTION       
   cmp  eax,IDYES
   je   Start
Exit

;===================================ПРОЦЕДУРЫ
;-----------------------------------0. Обнуление массива Y. Передача через регистры
NullY proc
   push eax             
   push ecx
   push ebx
@null:
   xor eax, eax
   mov [ebx], eax
   inc ebx
   dec ecx
   cmp ecx, 0
   je fin0
   jmp @null
fin0: 
   pop ebx 
   pop ecx
   pop eax
   ret 
NullY endp
;-----------------------------------1. Ввод. Передача через регистры
; На вход:
; ecx: максимальная длина строки
; Возвращает: (не то чтобы возвращает, а просто после процедуры в edi получаем это значение)
; edi:  последний байт строки (точка). Это сделано чтобы сразу получить значение последней буквы в последующем
; Потому что это понадобится в процедуре проверки
Input proc
   push eax ; сохранение регистров
   push ecx
   @input:
       inchar al
       mov [edi], al
       inc edi
       dec ecx
       jz fin1                 
       sub al, '.'
       jnz @input
   fin1: 
       pop ecx
       pop eax
       ret 
Input endp
;-----------------------------------2. Вывод. Передача через регистры
; На вход:
; ecx: максимальная длина строки
; esi: адрес строки
Output proc
   push esi
   push eax
   push ecx
   @output:
      mov al, [esi]
      inc esi
      outchar al
      dec ecx
      jz fin2
      sub al, '.'
      jnz @output
   fin2: 
      pop ecx
      pop eax
      pop esi
      ret 
Output endp

;--------------------------------------3. Проверка условия. Передача через регистры 
; На вход:
; esi: адрес конца строки
; ebx: адрес начала строки
; Возвращает:
; al: 1 если условие выполнено, 0 иначе
Check proc
   push esi
   push edx
   mov al, [esi]
   cmp al, 2Eh
   jne l1
   dec esi
   mov al, [esi]
   l1:
      cmp al, 'A'  
      jnb l1b
      l1a:
         xor al, al               ; условие не выполнено
         jmp fin3
      l1b: 
         cmp al, 'Z' ; 5Ah
         ja l1a 
         mov dl, al
         ;outchar dl
         ;newline
   l2:
      dec esi
      mov al, [esi]
      sub al, dl
      jz fin3
      cmp esi, ebx
      jnb l2
      mov al, 1                   ; выполнено
   fin3:
      pop edx
      pop esi
      ret
Check endp

;-------------------------------4. Первое правило. Передача параметров через стек 
; На вход:
; esi: адрес начала строки
; ecx: максмиальная длина строки  
First proc
   push ebp
   mov ebp, esp
   push esi
   push ecx
   push eax                     ; нужен для деления
   mov esi, [ebp + 8]
   mov ecx, [ebp + 12]
   mov dl, 10                   ; для mod
   outstr "First rule is executed"
   newline
   @first:
      mov al, [esi]
      inc esi
   @l1:
      cmp al, 'Z'             
      ja @m1 
      sub al, 'A'               
      jb @m1  
      xor ah, ah                ; место хранения остатка перед каждой буквой должно быть чистым
      div dl      
      mov al, '0'               ; кладем символ нуля (30h)
      add al, ah                ; потом кладем остаток
      mov [esi - 1], al         ; на нужное место в строке кладем полученное число (esi - 1 так как уже сдвинулись)
   @m1:                         ; не большая буква, игнорируем её
      dec ecx
      jz fin4
      sub al, '.'
      jnz @first
   fin4:
      pop eax
      pop ecx
      pop esi
      pop ebp
      ret 3 * 4
First endp

;----------------------------5. Второе правило. Передача через стек
; На вход:
; esi: адрес начала строки Str
; ecx: максмимальная длина строки  
; ebx: адрес вспомогательного массива Y
Second proc
   push ebp 
   mov ebp, esp  
   push esi
   push ecx
   push ebx
   mov esi, [ebp + 8]
   mov ecx, [ebp + 12]
   mov ebx, [ebp + 16]
   push edi             ; дополнительные параметры
   push eax
   push edx
   xor eax, eax
   push ecx
   push esi
   outstr "Second rule is executed"
   newline
   @second:              ; сопоставляем массив Str массиву Y
      mov al, [esi]      ; в al текущий элемент Str
      inc esi             
      mov edi, eax       ; в edi продублировали [esi] = текущий элемент Str
      add edi, ebx       ; к edi прибавили текущий элемент Y
      inc byte ptr [edi] ; сдвинули edi
      dec ecx           
      jz n0              
      sub al, '.'        
      jnz @second         ; пока не дойдет до точки
   n0:
      pop esi             ; сохраним длину и адрес строки перед самим алгоритмом
      pop ecx
      mov edi, esi        ; дублируем адрес строки 
   n1:
      mov al, [esi]
      inc esi
      mov dl, al          ; dl = текущий элемент
      mov al, [ebx + eax] ; записали текущий элемент в его ячейку в Y
      dec eax             ; убрать из текста, если уже был
      jnz n2
      mov [edi], dl       ; dl = текущий элемент
      inc edi             ; переход к следующему элементу
   n2: 
      cmp dl, '.'
      je fin5
      loop n1 
   fin5: 
      mov ebx, offset Y       ; Процедура обнуляет массив Y. Массив Str поменялся, и Y стал не нужен
      mov ecx, M
      call NullY

      pop edx
      pop eax
      pop edi
      pop ecx
      pop eax
      pop esi
      pop ebp
      ret 3 * 4
Second endp
   end Start