.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam

extern exit: proc
extern printf: proc
extern scanf: proc
extern fopen: proc
extern fclose: proc
extern fprintf: proc


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data


patru dd 4

element dd ?
ptrfisier dd ?
b dd ?
n dd ?
multime_A dd 100 dup(0)
multime_B dd 100 dup(0)
multime_dif dd 100 dup(0)

cc db "0",0
nr dd ?

mesaj_meniu db "Introduceti o operatie cu multimi",10,0
meniu_1 db "1.Verificare unicitate",10,0
meniu_2 db "2.Apartenenta",10,0
meniu_3 db "3.Diferenta ",10,0
meniu_4 db "4.Produs cartezian",10,0
meniu_5 db "5.Exit",10,0

fout db "rezultat.txt",0
format_fisier db "w",0

elem db "e = %d",10,0

mesaj_alta_comanda db 10,10,"Puteti introduce o alta comada: ",0
mesaj_comadaNegasita db "Introduceti alta comanda. Aceasta nu a fost gasita!",13,10,0
mesaj_iesire db 10,10,"Sfarsit program :) ",13,10,0
mesaj_citire db "Multime: ",0
mesaj_citireA db "Multime A: ",0
mesaj_citireB db "Multime B: ",0
mesaj_element db "e = ",0
mesaj_notDiferenta db "Multime diferenta este vida",10,0
new_line db " ",10,0
mesaj_apartine db "Rezultat: apartine",10,0
mesaj_nuApartine db "Rezultat: nu apartine",10,0
mesaj_intrerupere  db "=> nu se poate realiza operatia mai departe",10,0
mesaj_unic db "Verificare: elemente unice",10,0
mesaj_notUnic db "Verificare: elementele nu sunt unice",10,0
mesaj_fisier db 10,"Fisier rezultat: rezultat.txt",10,0
delimitare db 10,"....................................................................",10,0

format_int db "%d",0
format_string db "%s",0
format_elem_af db "%d ",0
format_multime db "%d%c",0
format_cartezian db "{%d, %d} ",0
comanda dd ?


.code

;macro pentru afisare mesaj la consola
afisare macro format, element
	push element
	push offset format
	call printf
	add esp,8
endm

;macro pentru afisarea elementelor unei multimi la consola
afisare_multime macro multime,n
local loopFor
	mov edi,0 ;index
	mov esi,n
	mov ecx,esi
	loopFor:
		mov esi,ecx
		afisare format_elem_af, multime[4*edi]
		
		inc edi
		mov ecx,esi
	loop loopFor
	
endm

;macro pentru citire multime
citire_multime macro multime_A,n
local citire
	mov esi,0 ;index
	citire:
	
		 push offset cc ;caracter
		 push offset nr
		 push offset format_multime ;se citeste cu format un numar si un caracter 
		 call scanf
		 add esp,12
		 
		 mov edi,nr
		 mov multime_A[4*esi], edi ;formare multime
		 
		 inc esi   ;incrementare index
		 mov n,esi  ;retinere numarul de elemente din multime
		 
		 xor eax,eax ;curatare
		 mov al, cc 
		 cmp al, 0Ah ;comparare caracter citit cu enter
		 jne citire	 ;daca nu se apasa enter se continua citirea, altfel nu
	
endm 


;macro pentru scriere in fisier 
scrie macro fisier,format,numar
	push numar
	push offset format
	push fisier
	call fprintf
	add esp,12
	
endm

;macro pentru scriere multime in fisier
scrie_multime macro fisier,multime,n
local printFisF

	mov ecx,n ;se repeta de atatea ori cate elemente are multimea
	mov esi,0 ;index
	printFisF:
			push ecx ;retinere valoare pentru ca se va modifica in macro ul de mai jos
			scrie fisier,format_elem_af,multime[4*esi]
			inc esi ;incrementare index pentru a trece la urmatorul element din multime
			pop ecx ;se ia de pe stiva valoarea lui ecx corespunzatoare loop ului
			
	loop printFisF
	
	;trecere la rand nou in fisier
	scrie [ebp+8],format_string,offset new_line

endm

;macro pentru a verifica daca multimea are elemente unice
unicitate macro fisier, multime,n
local loop1,loop2,fals,ext,adev

	mov ecx, n ;nr de elemente din multime
	cmp ecx,1 ;caz special, daca in multime este doar un element => este unic
	je adev
	
	;logica: compar fiecare element cu toti dupa el
	
	dec ecx ;pentru primul "for" ma duc doar pana la penultimul element
	mov esi,0 ;index pentru elementul ce va fi comparat cu toate elementele de dupa el
	loop1:
		mov edi, esi ; edi = index ul pentru elemetele de dupa
		inc edi 
		
		push ecx ;retin valoarea pentru ca se va modifica in loop2
		mov ebx,multime[4*esi] ;ebx retine elementul de comparat cu restul
		
		;al doilea "for" va avea un numar de pasi egal cu numarul total de elemente - indexul.elementului.de.comparat - 1
		mov ecx,n 
		sub ecx,esi
		dec ecx
		
		loop2:
			cmp ebx,multime[4*edi]
			je fals ;daca se afla 2 elemente egale se sare la final, nu mai are sens sa continue compararea, e clar ca nu sunt elemente unice
			inc edi ;daca nu, se continua compararea 
		loop loop2
		
		inc esi ;se trece la elementul urmator ce va fi comparat cu restul elemetelor de dupa el
		pop ecx ;se ia valoarea de pe stiva a lui ecx corespunzatoare loop1 ce am pus-o pe stiva la linia 194
	loop loop1
	
	adev: ;daca nu s-au gasit elemente egale se afiseaza mesaj de elemente unice
		afisare format_string, offset mesaj_unic ;la consola
		
		;in fisier
		scrie [ebp+8],format_string,offset mesaj_unic
		
		mov eax,1 ;fanionul va fi 1, adica elementele sunt unice
		jmp ext
	
	fals: ;daca s-au gasit elemente egale se afiseaza mesaj de elemente neunice
		afisare format_string, offset mesaj_notUnic ;la consola
		
		;in fisier
		scrie [ebp+8],format_string,offset mesaj_notUnic
	
		mov eax,0 ;fanionul va fi 0, adica elementele nu sunt unice
	ext:
endm

;functie efectiva pentru sectiunea din meniu cu verificare unicitate
;functia va avea ca argument la apel pointerul la fisier
fct_unicitate proc
	push ebp
	mov ebp,esp
	sub esp,4 ;variabila locata va retine numarul de elemente din multime
	
	scrie [ebp+8], format_int, comanda ;apel macro de scriere comanda in fisier
	
	;trecere la linie noua in fisier
	scrie [ebp+8],format_string,offset new_line
	
	;citire multime
	afisare format_string, offset mesaj_citire 
	citire_multime multime_A,[ebp-4]
	
	;scriere multime in fisier cu mesaj 
	scrie [ebp+8],format_string,offset mesaj_citire
	scrie_multime [ebp+8],multime_A,[ebp-4]
	
	unicitate [ebp+8],multime_A,[ebp-4] ;se apeleaza macro pentru verificare unicitate care si afiseaza mesaje corespunzatoare
	
	;scriere in fisier o secventa de "....." pentru a marca o delimitare intre operatii
	scrie [ebp+8],format_string,offset delimitare
	
	mov esp,ebp
	pop ebp
	ret 4
	
fct_unicitate endp	

;macro pentru verificare daca un element apartine multimii
verificare_apartine macro multime,nr,element
local verif,adevarat,final
	xor ecx,ecx
	mov ecx,nr ;numar de elemente
	verif:
		
		mov ebx,multime[4*ecx-4] ;nu conteaza ordinea, asa ca incep de la final ca sa ma folosesc doar de ecx, sa nu introduc alt registru
		
		cmp ebx ,element ;se verifica daca elemetul cautat este egal cu cel din multime 
		je adevarat ;in momentul in care il gaseste se opreste din cautat si sare la eticheta "adevarat"
		
	loop verif
	
	mov eax,0 ;s-a parcurs tot sirul, nu s-a gasit => se seteaza fanionul la 0, insemnand ca nu am gasit in multime elementul
	
	jmp final
	
	adevarat: 
		mov eax,1 ;se seteaza fanionul la 1, insemnand ca am gasit in multime elementul 
	
	final:	
	
endm

;functia efectiva pentru punctul de verificare apartenenta element citit
;functia va avea argument la apelare pointer ul la fisier
apartine proc
	push ebp
	mov ebp,esp
	sub esp,8 ;2 variabile locale, prima pentru elementul de verificat si a doua pentru numarul de elemente ale multimii
	
	scrie [ebp+8], format_int, comanda ;scriere comanda in fisier
	
	;trecere la linie noua in fisier 
	scrie [ebp+8],format_string,offset new_line
	
	;citire element pentru verificare apartenenta
	afisare format_string, offset mesaj_element
	lea eax,[ebp-4] ;element
	push eax
	push offset format_int
	call scanf
	add esp,8
	
	;scriere in fisier elemtul citit
	mov eax, [ebp-4]
	push eax
	push offset elem
	push [ebp+8]
	call fprintf
	add esp,12
	
	;citire multime
	afisare format_string, offset mesaj_citire
	citire_multime multime_A, [ebp-8]
	
	;scriere multime in fisier
	scrie [ebp+8],format_string,offset mesaj_citire
	scrie_multime [ebp+8],multime_A,[ebp-8]
	
	;verificare unicitare
	unicitate [ebp+8], multime_A,[ebp-8] ;eax = 0 FALS , 1 ADEVARAT
	
	cmp eax,0
	je intrerupt ;elemetele nu sunt unice => nu se continua 
	
	;altfel
	verificare_apartine multime_A,[ebp-8],[ebp-4] ;eax = 0 FALS , 1 ADEVARAT

	cmp eax,1
	je true ;daca apartine 
	
	;altfel
	afisare format_string, offset mesaj_nuApartine ;la consola

	;scriere in fisier mesaj de nu apartine
	scrie [ebp+8],format_string,offset mesaj_nuApartine

	jmp finish

	true:
		afisare format_string, offset mesaj_apartine ;la consola
	
		;scriere in fisier mesaj de apartine
		scrie [ebp+8],format_string,offset mesaj_apartine
	
		jmp finish	
		
	intrerupt:
	
		afisare format_string, offset mesaj_intrerupere ;la consola
		
		;scriere in fisier mesaj de intrerupt, elementele nu sunt unice
		scrie [ebp+8],format_string,offset mesaj_intrerupere
		
	finish:
		
		;scriere in fisier o secventa de "....." pentru a marca o delimitare intre operatii
		scrie [ebp+8],format_string,offset delimitare
		
		mov esp,ebp
		pop ebp
		ret 4
		
apartine endp 


macro_diferenta macro multime_A, multime_B, elemA, elemB ;face diferenta dintre A si B -> A\B
local forrA, contA
	mov ecx, elemA ;numarul de elemente din multimea A
	mov esi,0 ;index pentru elementele din A
	forrA:
		push ecx ;punere pe stiva valoare pentru ca se va modifica in macro de mai jos
		verificare_apartine multime_B,elemB,multime_A[4*esi] ;se verifica daca elementul din A apartine in B
		cmp eax,0 ; 0 = nu apartine
		jne contA  ;deci, daca nu e egal cu 0 => apartine si se continua verificarea cu urmatorul element din A
		
		;daca nu se gaseste in B, atunci se pune in multimea diferenta elementul respectiv
		mov edx, multime_A[4*esi] ;elementul de diferenta
		mov multime_dif[4*edi],edx ;se pune in multimea diferenta
		inc edi ;incrementare index pentru multimea diferenta
	
		contA:
		inc esi ;incrementare index pentru multimea A
		pop ecx ;se ia de pe stiva valoare corespunzatoare loop ului ce am pus-o pe stiva la linia 448
		
	loop forrA
	
endm

;fuctie pentru diferenta dintre 2 multimi
;functia va avea ca argument la apel pointer ul la fisier
diferentaAB proc
	push ebp
	mov ebp,esp
	sub esp,12 ;2 variabile locale, prima pentru numarul de elemente ale multimii A si a doua pentru numarul de elemente ale multimii B
	
	scrie [ebp+8], format_int, comanda ;scriere in fisier comanda
	
	;trecere la linie noua
	scrie [ebp+8], format_string,offset new_line
	
	;citire multime A
	afisare format_string, offset mesaj_citireA
	citire_multime multime_A,[ebp-4]
	
	;scriere multime A in fisier
	scrie [ebp+8],format_string,offset mesaj_citireA
	
	scrie_multime [ebp+8],multime_A,[ebp-4]
	
	
	unicitate [ebp+8],multime_A,[ebp-4] ;verificare unicitate multimea A
	cmp eax,0
	je intrerupt ;se termina programul daca nu sunt unice, adica eax = 0
	
	;altfel
	;citire multime B
	afisare format_string, offset mesaj_citireB	
	citire_multime multime_B,[ebp-8]
	
	;afisare multime B in fisier 
	scrie [ebp+8],format_string,offset mesaj_citireB
	
	scrie_multime [ebp+8],multime_B,[ebp-8]
	
	
	unicitate [ebp+8], multime_B,[ebp-8] ;verificare unicitate multimea B
	cmp eax,0
	je intrerupt ;se termina programul daca nu sunt unice, adica eax = 0
	
	;altfel, elementele sunt unice in ambele multimi => se poate trece la diferenta
	
	mov edi,0 ;index pentru elementele din multimea diferent
	
	;A\B
	macro_diferenta multime_A, multime_B, [ebp-4], [ebp-8]
	
	;B\A
	macro_diferenta multime_B, multime_A, [ebp-8], [ebp-4]
	

	cmp edi,0 ;edi = 0 => multimea diferenta este vida si se afiseaza mesaj corespunzator
	jne dif ;daca edi!=0 se afiseaza multimea diferenta
	
	afisare format_string, offset mesaj_notDiferenta ;la consola
	
	;in fisier
	scrie [ebp+8],format_string,offset mesaj_notDiferenta
	
	jmp endd
	
	;afisare multime diferenta
	dif:
		mov [ebp-12],edi
		
		afisare_multime multime_dif,[ebp-12] ;la consola
		scrie_multime [ebp+8],multime_dif,[ebp-12] ;in fisier
		
	jmp endd
	
	intrerupt:
		afisare format_string, offset mesaj_intrerupere ;la consola
		
		;in fisier
		scrie [ebp+8],format_string,offset mesaj_intrerupere
	endd:
	
		;scriere in fisier o secventa de "....." pentru a marca o delimitare intre operatii
		scrie [ebp+8],format_string,offset delimitare
	
		mov esp,ebp
		pop ebp
		ret 4

diferentaAB endp

;functie care determina produsul catezian
;functia va avea ca argument la apel pointer ul la fisier
cartezian proc
	push ebp
	mov ebp,esp
	sub esp,8 ;2 variabile locale, prima pentru numarul de elemente ale multimii A si a doua pentru numarul de elemente ale multimii B
	
	scrie [ebp+8], format_int, comanda ;sciere comanda in fisier
	
	;trecere la rand nou
	scrie [ebp+8],format_string,offset new_line
	
	;citire multime A
	afisare format_string, offset mesaj_citireA
	citire_multime multime_A,[ebp-4]
	
	;scriere multime A in fisier
	scrie [ebp+8],format_string,offset mesaj_citireA
	scrie_multime [ebp+8],multime_A,[ebp-4]
	
	;verificare elemente unice multime A
	unicitate [ebp+8],multime_A,[ebp-4]
	cmp eax,0
	je intrerupt ;nu sunt unice se sare la final operatie
	
	;altfel
	;citire multime B
	afisare format_string, offset mesaj_citireB	
	citire_multime multime_B,[ebp-8]
	
	;scriere multime B in fisier
	scrie [ebp+8],format_string,offset mesaj_citireB
	scrie_multime [ebp+8],multime_B,[ebp-8]
	
	;verificare elemente unice multime B
	unicitate [ebp+8],multime_B,[ebp-8]
	cmp eax,0
	je intrerupt ;nu sunt unice se sare la final operatie
	
	;altfel, daca multimile au elemente unice se trece la realizarea produsului cartezian
	
	mov ecx, [ebp-4] ;numarul elementelor din A
	mov esi,0 ;index pentru multimea A
	loop1:
		push ecx ;se pastreaza pe stiva vechea valoare a lui ecx corespunzatoare loop1, deoarece aceasta se va modifica pentru loop2
		mov ecx,[ebp-8] ;creez ecx pentru loop2, deci ecx = numarul.de.elemente.din.B
		mov edi,0 ;index pentru parcurgere multime B
		loop2:
			push ecx ;se pastreaza pe stiva vechea valoare a lui ecx corespunzatoare loop2, deoarece se va modifica 
			mov eax, multime_A[4*esi] ;elementul din A
			mov ebx, multime_B[4*edi] ;elementul din B
			
			;afisare pereche
			push ebx
			push eax
			push offset format_cartezian
			call printf
			add esp,12
			
			;se refac registrele, sa retina elementul din A si elementul din B, deoarece la apelul functiei printf de mai sus s-au modificat
			mov eax, multime_A[4*esi]
			mov ebx, multime_B[4*edi]
			
			;afisare pereche in fisier
			push ebx
			push eax
			push offset format_cartezian
			push [ebp+8]
			call fprintf
			add esp,16
			
			
			inc edi ;se trece la urmatorul element din B
			pop ecx ;se ia de pe stiva valoarea lui ecx corespunzatoare loop2
		
		loop loop2
		
		inc esi ;se trece laa urmatorul element din A
		pop ecx ;se ia de pe stiva valoarea lui ecx corespunzatoare loop1
		
	loop loop1
	
	
	jmp finish
	intrerupt:
		afisare format_string, offset mesaj_intrerupere ;la consola
		
		;in fisier 
		scrie [ebp+8],format_string,offset mesaj_intrerupere
	
	finish:
		;scriere in fisier o secventa de "....." pentru a marca o delimitare intre operatii
		scrie [ebp+8],format_string,offset delimitare
	
		mov esp,ebp
		pop ebp
		ret 4
cartezian endp


start:
	;deschidere fisier
	push offset format_fisier
	push offset fout
	call fopen
	add esp,8
	
	mov ptrfisier, eax ;retin pointer la fisier
	
	;scriere MENIU in fisier
	scrie ptrfisier,format_string,offset mesaj_meniu
	
	scrie ptrfisier,format_string,offset meniu_1
	
	scrie ptrfisier,format_string,offset meniu_2
	
	scrie ptrfisier,format_string,offset meniu_3
	
	scrie ptrfisier,format_string,offset meniu_4
	
	scrie ptrfisier,format_string,offset meniu_5

	scrie ptrfisier,format_string,offset delimitare
	
	;afisare MENIU la consola
	afisare format_string, offset mesaj_meniu
	afisare format_string, offset meniu_1
	afisare format_string, offset meniu_2
	afisare format_string, offset meniu_3
	afisare format_string, offset meniu_4
	afisare format_string, offset meniu_5
	jmp here
	
	;INTRODUCERE COMANDA
	citire_comanda:
		afisare format_string, offset mesaj_alta_comanda ;la consola
		
		;in fisier
		scrie ptrfisier,format_string,offset mesaj_alta_comanda
		
			
		here:
			;citire comanda
			push offset comanda
			push offset format_int
			call scanf
			add esp,8
	
			mov esi, comanda ;esi retine comanda ce a fost introdusa
			

			cmp esi,1
			je verificare
		
			cmp esi,2
			je apartenenta
		
			cmp esi,3
			je diferenta
		
			cmp esi,4
			je produs_cartezian
			
			cmp esi,5
			je iesire
	
	
			jmp comandaNegasita
	
		verificare: 
			push ptrfisier
			call fct_unicitate
			jmp citire_comanda
		
		
		apartenenta:
			push ptrfisier
			call apartine
			jmp citire_comanda
		
		
		diferenta:
			push ptrfisier
			call diferentaAB
			jmp citire_comanda
		
		
		produs_cartezian:
			push ptrfisier
			call cartezian
			jmp citire_comanda
	
		comandaNegasita:
			scrie ptrfisier,format_int,comanda
			
			scrie ptrfisier,format_string,offset new_line
			
			scrie ptrfisier,format_string,offset comandaNegasita
			
			afisare format_string, offset mesaj_comadaNegasita
			jmp citire_comanda
	

	;terminarea programului
	iesire:
		scrie ptrfisier,format_int,comanda
		scrie ptrfisier,format_string,offset new_line
		
		scrie ptrfisier,format_string,offset mesaj_iesire
		
		push ptrfisier
		call fclose
		add esp,4
		
		afisare format_string, offset mesaj_iesire
		afisare format_string, offset mesaj_fisier
	

	push 0
	call exit
end start
