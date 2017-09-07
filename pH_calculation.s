.section .text
	
	.global controllo

controllo:
	
	pushl %ebp
	movl %esp, %ebp

	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx

	movl 8(%ebp), %eax    #bufferin
	movl 12(%ebp), %ebx		#bufferout_asm
	movb $48, %cl			#Porto a zero %ecx che mi serve per contare NCK
	movb $48, %ch
	
	cmpb $0, (%eax)			#Controllo se il file è vuoto
	je return
	
		movb $0, %dl
		ciclo:
			cmpb $48, (%eax) 					#INIT
			je spenta 							#Macchina spenta se è a 0
				cmpb $49, 2(%eax) 				#RESET
				je spenta						#Resetta se è a 1, salta per resettare
					jmp conta
					controllo_ph:
						cmpb $48, 4(%eax)   
						jne basica					#Se la prima cifra è != 0 è basica
							cmpb $54, 5(%eax)
							jl acida				#Se la seconda cifra è < 6 è acida
								cmpb $56, 5(%eax)
								jl neutra			#Se la seconda cifra < 8 è neutra
									je unita 		#Se è uguale a 8 controllo la terza cifra
										jmp basica		#Tutto il resto è basico
				
			unita:
				cmpb $48, 6(%eax)
				je neutra			#Se la terza cifra è uguale a 0 è neutro
					jmp basica		#Tutto il resto è basico                 

			basica:
				cmpb $66, %dl		#Se il valore precedente è diverso da quello attuale azzero %ecx
				jne azzera_contatore_basico
					riprendi_basico:
						movb $66, (%ebx)	#Stampo lo stato del sistema
						movb $66, %dl	
						cmpb $48, %ch		#Controllo se ho raggiunto i 5 cicli di clock, per farlo controllo prima le decine e poi le unità
						jne valvola_basica 		#Salto se ho un valore != 0
							cmpb $53, %cl
							jge valvola_basica 		#Salto se ho un valore >= 1
								movb $44, 1(%ebx) 	#Stampo NCK Incrementato
								movb %ch, 2(%ebx)
								movb %cl, 3(%ebx)
								movb $44, 4(%ebx)	#Stampo la valvola
								movb $45, 5(%ebx)
								movb $45, 6(%ebx)
								jmp fine
			
			acida:
				cmpb $65, %dl		#Se il valore precedente è diverso da quello attuale azzero %ecx
				jne azzera_contatore_acido
					riprendi_acido:
						movb $65, (%ebx)	#Stampo lo stato del sistema
						movb $65, %dl
						cmpb $48, %ch		#Controllo se ho raggiunto i 5 cicli di clock, per farlo controllo prima le decine e poi le unità
						jne valvola_acida 		#Salto se ho un valore != 0
							cmpb $53, %cl
							jge valvola_acida 		#Salto se ho un valore >= 1
								movb $44, 1(%ebx) 	#Stampo NCK Incrementato
								movb %ch, 2(%ebx)
								movb %cl, 3(%ebx)
								movb $44, 4(%ebx)	#Stampo la valvola
								movb $45, 5(%ebx)
								movb $45, 6(%ebx)
								jmp fine

			neutra:
				cmpb $78, %dl		#Se il valore precedente è diverso da quello attuale azzero %ecx
				jne azzera_contatore_neutro
					riprendi_neutro:
						movb $78, (%ebx)	#Stampo lo stato del sistema
						movb $78, %dl
						movb $44, 1(%ebx) 	#Stampo NCK Incrementato
						movb %ch, 2(%ebx)
						movb %cl, 3(%ebx)
						movb $44, 4(%ebx)	#Stampo la valvola
						movb $45, 5(%ebx)
						movb $45, 6(%ebx)
						jmp fine

			conta:
				cmpb $57, %cl 		#Controllo se ho un 9 come unità
				je decine			#Se ce l'ho salto
					addb $1, %cl 	#Incremento di 1 le unità se non è già 9
					jmp controllo_ph

			decine:
				addb $1, %ch 	#Incremento di 1 le decine
				movb $48, %cl 	#Porto a zero le unità
				jmp controllo_ph

			valvola_basica:
				movl $44, 1(%ebx) 	#Stampo NCK Incrementato
				movb %ch, 2(%ebx)
				movb %cl, 3(%ebx)
				movl $44, 4(%ebx)	#Stampo la valvola
				movl $65, 5(%ebx)
				movl $83, 6(%ebx)
				jmp fine

			valvola_acida:
				movl $44, 1(%ebx) 	#Stampo NCK Incrementato
				movb %ch, 2(%ebx)
				movb %cl, 3(%ebx)
				movl $44, 4(%ebx)	#Stampo la valvola
				movl $66, 5(%ebx)
				movl $83, 6(%ebx)
				jmp fine

			azzera_contatore_basico:
				movb $48, %cl			#Porto a zero %ecx
				movb $48, %ch
				jmp riprendi_basico

			azzera_contatore_acido:
				movb $48, %cl			#Porto a zero %ecx
				movb $48, %ch
				jmp riprendi_acido

			azzera_contatore_neutro:
				movb $48, %cl			#Porto a zero %ecx
				movb $48, %ch
				jmp riprendi_neutro
			
			spenta:
				movb $0, %dl
				movl $45, (%ebx)
				movl $44, 1(%ebx)
				movl $45, 2(%ebx)
				movl $45, 3(%ebx)
				movl $44, 4(%ebx)
				movl $45, 5(%ebx)
				movl $45, 6(%ebx)

			fine:
				movb $10, 7(%ebx)
				addl $8, %eax
				addl $8, %ebx
				cmpb $0, (%eax)
				jne ciclo
					return:
						popl %eax
						popl %ebx
						popl %ecx
						popl %edx
						popl %ebp
						ret
