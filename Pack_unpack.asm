include settings.inc
include io2020.inc  
.stack 4096

; aaaa aaae eeee eefd // a = age / e = exp / f = form / d = disability
	
.code
input proc public ; результат в ax
   push ebp
   mov  ebp, esp

   push ebx
   push ecx
   push edx
   push edi
   push esi
   mov ebx, [ebp + 8]  ; age
   mov ecx, [ebp + 12] ; exp
   mov edx, [ebp + 16] ; form
   mov edi, [ebp + 20] ; disability
   
   xor esi, esi
   and ebx, 1111111b
   shl ebx, 9
   or esi, ebx
   
   and ecx, 1111111b
   shl ecx, 2
   or esi, ecx

   and edx, 1
   shl edx, 1
   or esi, edx

   and edi, 1
   or esi, edi

   mov ax, si
       
   pop esi
   pop edi
   pop edx
   pop ecx
   pop ebx
   pop ebp
   ret  4 * 4
input endp

output proc public
   push ebp
   mov  ebp,esp
   push eax
   push ebx
   push ecx
   push edx 
   push esi
   mov esi, [ebp + 8]  
   mov eax, [ebp + 12] ; age
   mov ebx, [ebp + 16] ; exp
   mov ecx, [ebp + 20] ; form
   mov edx, [ebp + 24] ; disability

   mov word ptr [eax], si
   and word ptr [eax], 1111111000000000b
   shr word ptr [eax], 9
   
   mov word ptr [ebx], si
   and word ptr [ebx], 0000000111111100b
   shr word ptr [ebx], 2

   mov word ptr [ecx], si
   and word ptr [ecx], 0000000000000010b
   shr word ptr [ecx], 1

   mov word ptr [edx], si
   and word ptr [edx], 0000000000000001b
      
   pop esi
   pop edx
   pop ecx
   pop ebx
   pop eax
   pop ebp
   ret  5 * 4
output endp
end