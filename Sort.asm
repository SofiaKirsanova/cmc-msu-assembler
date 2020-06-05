include console.inc

COMMENT *
Сортировка слов без знака простым выбором по убыванию, на нужное место ставим минимум *

N equ 10
M equ 6
.data 
arr1 dw N dup (?)
arr2 dw M dup (?) 
.code

;=================================== ОСНОВНАЯ ПРОГРАММА
Start:
;-----------------------------------1. ВВод большого (arr1) и маленького (arr2) массивов
   ;ClrScr
   ConsoleTitle "Сортировка простым выбором"
   outstr "Enter "
   outint N
   outstr " unsigned words"
   newline

   mov ecx, N                       
   mov esi, offset arr1                      
   push esi
   push ecx
   call Input
   newline

   outstr "Enter "
   outint M
   outstr " unsigned words"
   newline 
   mov ecx, M                       
   mov esi, offset arr2                    
   push esi
   push ecx
   call Input
   newline
   newline
;-----------------------------------2. Вывод большого и маленького массивов
   outstr "Array1 is : "  
   mov ecx, N                       
   mov esi, offset arr1                    
   push esi
   push ecx
   call Output
   newline

   mov ecx, M  
   outstr "Array2 is : "                      
   mov esi, offset arr2                      
   push esi
   push ecx
   call Output
   newline
   newline
;-----------------------------------3. Сортировка массивов
   mov esi, offset arr1                   ; индекс текущего элемента
   mov eax, offset arr1                   ; eax = начало массива, его не меняем и к нему двигаемся справа налево            
   add esi, 2 * N - 2                     ; (type arr) * N - type arr = индекс последнего элемента
   push esi
   push eax
   call Sort

   mov esi, offset arr2                   ; индекс текущего элемента
   mov eax, offset arr2                   ; eax = начало массива, его не меняем и к нему двигаемся справа налево            
   add esi, 2 * M - 2                     ; (type arr) * M - type arr = индекс последнего элемента
   push esi
   push eax
   call Sort                          
;-----------------------------------4. Отсортированные массивы распечатываются
   mov ecx, N                       
   mov esi, offset arr1 
   outstr "Sorted array1 is: "                   
   push esi
   push ecx
   call Output
   newline

   mov ecx, M                       
   mov esi, offset arr2  
   outstr "Sorted array2 is: "                    
   push esi
   push ecx
   call Output
   newline
   newline
Exit
;===================================ПРОЦЕДУРЫ

;-----------------------------------Ввод
Input proc      ; Процедура ввода. Передача параметров через стек. ecx = количество элементов, esi = адрес начала массива
    push ebp
    mov ebp, esp
    mov ecx, [ebp + 8]
    mov esi, [ebp + 12]
@Input:
    inint eax                      
    cmp eax, 0FFFFh     ; проверка правильности ввода                     
    ja @Input                             
    mov word ptr [esi], ax               
    add esi, 2
    loop @Input 
    pop ebp                           
    ret 2 * 4
Input endp

;-----------------------------------Вывод
Output proc       ; Процедура вывода. Передача параметров через стек. ecx = количество элементов, esi = адрес начала массива 
    push ebp
    mov ebp, esp
    mov ecx, [ebp + 8]
    mov esi, [ebp + 12]
@Output:
   outword word ptr [esi]
   outchar " "
   add esi, 2  
   dec ecx
   jne @Output 
   pop ebp
   ret 2 * 4
Output endp 
;-----------------------------------Сортировка        
Sort proc ; Процедура сортировки. Передача параметров через стек. esi = индекс текущего элемента (в начале самый последний слева), eax = начало массива
   push ebp
   push eax           ; сохранение всех используемых регистров
   push ebx
   push ecx
   push edx
   push esi
   push edi
   mov ebp, esp
   mov eax, [ebp + 32]
   mov esi, [ebp + 36]
   mov ebx, esi                           ; адрес массива (справа)

   Cikl:   
   cmp eax, ebx                           ; границы сомкнулись 
   jz Final
   mov esi, ebx                           ; в текущий элемент кладём "правую" границу
; ищем минимум от начала (eax) до esi 
   mov edi, esi                           ; адрес текущего минимума, то есть сохранили адрес минимума в edi
   mov dx, word ptr [esi]                 ; dx = текущий min    
   sub esi, 2                            
Min:  
   cmp esi, eax                           ; не вышли ли за границу массива справа
   jnae L2                                ; если да то и не надо продолжать	
   cmp dx, word ptr [esi]                 ; сравним минимум и элемент
   jnae L1                                ; нет, не меньше, надо сместиться и идти дальше
   mov edi, esi
   mov dx, word ptr [esi]
L1:
   sub esi, 2
   jmp Min	
L2:
   mov cx, word ptr [edi]
   xchg word ptr [ebx], cx
   xchg word ptr [edi], cx
   sub ebx, 2
   jmp Cikl
Final:
   pop edi
   pop esi
   pop edx
   pop ecx
   pop ebx
   pop eax
   pop ebp	
   ret 2 * 4
Sort endp

   end Start