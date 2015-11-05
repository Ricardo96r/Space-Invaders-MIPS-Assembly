# Creado por: Ricardo Rodríguez <ricardo96r@gmail.com>
# Ultima edición: 5/11/15
#
# Gracias a: https://dtconfect.wordpress.com/projects/year2/mips-snake-and-primlib/
#
# Para jugarlo primero: 0- Abrir MARS
#			1- Tools -> Bitmap Display
#			2- unit width in pixel: 16 / unit height in pixel: 16
#			3- Display Width in Pixels: 512 / Display Height in Pixels: 512
#			4- Base address for display: $gp
#			5- Tools -> Keyboard and Display
#			7- Connect to MIPS
#			8- Assemble y RUN
#
# Intrucciones:		- Se mueve hacia la  izquierda con "a" minuscula!
#			- Se mueve hacia la derecha con "d" minuscula!
#			- Se dispara con la tecla espacio
#			- Se tiene que jugar con letras minusculas (bloq mayús desactivado)
#			- Los pixeles azules son el nivel actual (1, 2 o 3)
#			- Los Pixeles rosados son las vidas restantes
#
# NOTA: Los popups de MARS SYSCALL(50-55) aveces dan error y se quedan en blanco, 
#	por lo cual hay que cerrar el MARS y volverlo a abrir. Este error es culpa de MARS.
#
# NOTA: El archivo macro.asm tiene que estar en la misma carpeta que este archivo.
.include "macros.asm"

.data
ancho: 				.byte 32 	# Cantidad de pixeles que entran en fila.    512 width  / 16 unit width  = 32
largo: 				.byte 32 	# Cantidad de pixeles que entran en columna. 512 height / 16 unit height = 32

velocidad:			.byte 60	# Cada ves que se ejecuta el loop del juego. Milisegundos.

color_borde: 			.word 0x00228b22	
color_borde_ultima: 		.word 0x00ff0000
color_jugador: 			.word 0x0032cd32
color_fondo: 			.word 0x00000000
color_invasor: 			.word 0x0000FF00
color_disparo: 			.word 0x00ff0000
color_win: 			.word 0x0000FF00
color_lose: 			.word 0x00ff0000
color_invasor_disparo: 		.word 0x00ffff00
color_vidas: 			.word 0x00FF00FF
color_niveles:			.word 0x006666FF
color_invasor_nivel_2:		.word 0x00FF9933
color_invasor_nivel_3:		.word 0x00B266FF

jugador: 			.space 16 	# 4 bloques de 16x16 pixeles
jugador_x: 			.byte 16	# Posicion incial del jugador
jugador_size: 			.byte 16	# Cantidad de pixeles en word 4 x 4 =16
jugador_vidas: 			.byte 3		# Vidas restantes del jugador
jugador_disparo: 		.word 0 	# Direccion en memoria de la posicion del disparo
jugador_disparo_existe: 	.byte 0 	# 0 = no existe, 1 = existe el disparo
jugador_disparo_mover:  	.byte 0 	# Contador usado para la velocidad. No Cambiar
jugador_disparo_velocidad: 	.byte 1 	# Tiempo que tarda en moverse el disparo. Tarda 60ms*1 = 60ms

.align 2
invasor:			.space 160 	# 40 invasores. MATRIZ 10X4
invasor_size: 			.byte 40 	# Cantidad de invasores
invasor_size_x: 		.byte 10 	# Posicion X de la matriz
invasor_size_y: 		.byte 4		# Posicion Y de la matriz
invasor_vivos:			.space 40 	# 0 = muerto, 1 = vivo. vector lleno de unos
invasor_vivos_contador: 	.byte 40 	# al llegar a cero se gana el juego
invasor_x: 			.byte 3 	# Posicion x inicial. Valores legales 3 a 10
invasor_y: 			.byte 2 	# posicion y inicial. Valores legales 2 a 25(Depende del ultimo invasor)
invasor_sentido: 		.byte 0 	# 0 = derecha, 1 = izquierda
invasor_mover: 			.byte 0 	# Contador usado para la velocidad
invasor_velocidad: 		.byte 12	# 60ms x 12 = 720ms
invasor_disparo_data: 		.word 0 	# Direccion en memoria de la posicion del disparo
invasor_disparo_existe: 	.byte 0 	# 0 = no existe, 1 = existe
invasor_disparo_mover: 		.byte 0		# Contador utilizado para la velocidad
invasor_disparo_velocidad: 	.byte 1		# Tiempo que tarda en moverse el disparo. Tarda 60ms*1 = 60ms

niveles:			.byte 1		# Contador de niveles. El ultimo nivel es el 3

win_dialogo:			.asciiz "! Ganaste ! ¿Quieres continuar al siguiente nivel?"
lose_dialogo:			.asciiz "! Perdiste ! ¿Quieres jugar denuevo?"
fin_dialogo:		.	.asciiz "! Has ganado todos los niveles !"
.text
.globl Main_iniciar
Main_iniciar:	
	lb $a0 color_fondo
	jal background 		# Limpiar pantalla, de juegos anteriores
	jal actualizar_borde
	jal player
	jal mostrar_jugador
	jal invasores
	jal mostrar_invasores

Main_loop:
	jal mover_disparo
	jal mover_invasores
	jal invasor_disparo
	jal invasor_mover_disparo
	lb $t0 velocidad
	sleep($t0)
	lw $t0 0xFFFF0000		
	blez $t0 Main_loop
	
Main_Obtener_Tecla:
	jal Obtener_tecla	# Obtener el valor de la tecla presionada
	move $t0 $v0
			
Main_mover_izquierda:
	bne $t0 0x02000000 Main_mover_derecha # A
	jal limpiar_jugador
	jal mover_jugador_i
	jal mostrar_jugador
	j Main_loop

Main_mover_derecha:
	bne $t0 0x01000000 Main_disparar # D
	jal limpiar_jugador
	jal mover_jugador_d
	jal mostrar_jugador
	j Main_loop
	
Main_disparar:
	bne $t0 0x03000000 Main_loop # ESPACIO
	jal disparo
	jal mostrar_disparo
	j Main_loop

Main_win:
	lb $t0 niveles
	beq $t0 3 Main_fin
	lw $a0 color_win
	jal background
	li $v0 50
	la $a0 win_dialogo
	syscall
	beqz $a0 siguiente_nivel
	j Main_exit

Main_fin:
	lw $a0 color_win
	jal background
	li $v0 55
	la $a0 fin_dialogo
	li $a1 1
	syscall
	j Main_exit

Main_lose:
	lw $a0 color_lose
	jal background
	li $v0 50
	la $a0 lose_dialogo
	syscall
	beqz $a0 reiniciar
	j Main_exit
	
Main_exit:
	exit()

####################################################
# Devuelve la direccion a guadar el pixel en el $gp
# $a0 = x, $a1 = y
# Retorna $v0
DireccionEnMemoria:
	lbu $v0 ancho
	mulu $a1 $a1 $v0
	addu $v0 $a0 $a1
	sll $v0 $v0 2
	addu $v0 $v0 $gp
	jr $ra

####################################################
# Agrega el fondo
# $a0 = color
background:
	lb $a1 ancho
	lb $a2 largo
	mul $a2 $a1 $a2
	sll $a2 $a2 2 
	add $a2 $a2 $gp
	move $a1 $gp
background_loop:	
	sw $a0 ($a1)
	add $a1 $a1 4
	blt $a1 $a2 background_loop
	jr $ra	
	
####################################################
# Agrega el borde a la pantalla
# No Retorna
borde:	move $t0 $ra
	lw $t1 color_borde
	lb $t2 ancho
borde_a:li $t3 0 # X
	li $t4 0 # Y
borde_arriba:
	move $a0 $t3
	move $a1 $t4
	jal DireccionEnMemoria
	sw $t1 ($v0)
	addi $t3 $t3 1
	bne $t3 $t2 borde_arriba
borde_i:li $t3 0
	li $t4 0
borde_izquierda:
	move $a0 $t3
	move $a1 $t4
	jal DireccionEnMemoria
	sw $t1 ($v0)
	addi $t4 $t4 1
	bne $t4 $t2 borde_izquierda
borde_d:li $t3 31
	li $t4 0
borde_derecha:
	move $a0 $t3
	move $a1 $t4
	jal DireccionEnMemoria
	sw $t1 ($v0)
	addi $t4 $t4 1
	bne $t4 $t2 borde_derecha
borde_b:li $t3 0
	li $t4 31
borde_abajo:
	move $a0 $t3
	move $a1 $t4
	jal DireccionEnMemoria
	sw $t1 ($v0)
	addi $t3 $t3 1
	bne $t3 $t2 borde_abajo
borde_return:
	jr $t0
	
####################################################
# Mostrar vidas
mostrar_vidas:
	sw $ra -4($sp)
	lb $t0 jugador_vidas
	lw $t1 color_vidas
	li $a0 31
	li $a1 2
	jal DireccionEnMemoria
	sw $t1 ($v0)
	beq $t0 1 mostrar_vidas_return
	li $a0 31
	li $a1 4
	jal DireccionEnMemoria
	sw $t1 ($v0)
	beq $t0 2 mostrar_vidas_return
	li $a0 31
	li $a1 6
	jal DireccionEnMemoria
	sw $t1 ($v0)
mostrar_vidas_return:
	lw $ra -4($sp)
	jr $ra

####################################################
# Mostrar nivel al lado izquierdo
mostrar_nivel:
	sw $ra -4($sp)
	lb $t0 niveles
	lw $t1 color_niveles
	li $a0 0
	li $a1 2
	jal DireccionEnMemoria
	sw $t1 ($v0)
	ble $t0 1 mostrar_nivel_return
	li $a0 0
	li $a1 4
	jal DireccionEnMemoria
	sw $t1 ($v0)
	ble $t0 2 mostrar_nivel_return
	li $a0 0
	li $a1 6
	jal DireccionEnMemoria
	sw $t1 ($v0)
mostrar_nivel_return:
	lw $ra -4($sp)
	jr $ra
	
####################################################
# Actualizar el borde
actualizar_borde:
	sw $ra -8($sp)
	jal borde
	jal mostrar_vidas
	jal mostrar_nivel
	lw $ra -8($sp)
	jr $ra

####################################################
# Crea el disparo generado por el jugador
disparo:sw $ra ($sp)
	lb $t2 jugador_disparo_existe
	bnez $t2 disparo_return
	lb $a0 jugador_x
	li $a1 27
	jal DireccionEnMemoria
	sw $v0 jugador_disparo
	li $t1 1
	sb $t1 jugador_disparo_existe
disparo_return:
	lw $ra ($sp)
	jr $ra
	
####################################################
# Mover disparo del jugador hacia arriba
mover_disparo:
	sw $ra ($sp)
	lb $t2 jugador_disparo_existe
	beqz $t2 mover_disparo_return 
	lb $t1 jugador_disparo_mover
	lb $t2 jugador_disparo_velocidad
	addi $t1 $t1 1
	sb $t1 jugador_disparo_mover
	bne $t1 $t2 mover_disparo_return # para que se mueva mas lento el disparo
	jal limpiar_disparo
	jal fin_disparo
	li $t1 0
	sb $t1 jugador_disparo_mover
	lw $t0 jugador_disparo
	subi $t0 $t0 128
	sw $t0 jugador_disparo
	jal mostrar_disparo
mover_disparo_return:
	lw $ra ($sp)
	jr $ra

####################################################
# Limpia el disparo.
limpiar_disparo:
	lw $t0 jugador_disparo
	lw $t1 color_fondo
	sw $t1 0($t0)
	jr $ra
	
####################################################
# Muestra el disparo del jugador
mostrar_disparo:
	lw $t0 jugador_disparo
	lw $t1 color_disparo
	sw $t1 ($t0)
	jr $ra
	
####################################################
# Fin disparo. Cuando el disparo llega a su fin. 
# Puede llegar al borde o a un invasor
fin_disparo:
	lw $t0 jugador_disparo
	move $t1 $t0
	subi $t1 $t1 128
	ble $t1 0x1000807C fin_disparo_done # llego a la primera fila x = 0
	lw $t2 ($t1)
	lw $t3 color_fondo
	lw $t4 color_invasor_disparo
	beq $t4 $t2 fin_disparo_done
	bne $t2 $t3 fin_disparo_a_invasor
	b fin_disparo_return
fin_disparo_a_invasor:
	li $t0 0 # contador de bytes
	# $t1 del label anterior
	li $t2 0 # contador
fin_disparo_a_invasor_loop:
	lw $t3 invasor($t0)
	beq $t1 $t3 fin_disparo_a_invasor_eliminar
	addi $t0 $t0 4
	addi $t2 $t2 1
	bne $t2 40 fin_disparo_a_invasor_loop
	nop
fin_disparo_a_invasor_eliminar:
	li $t0 0
	sb $t0 invasor_vivos($t2)
	lb $t1 invasor_vivos_contador
	subi $t1 $t1 1
	sb $t1 invasor_vivos_contador
	li $t0 0
	sb $t0 jugador_disparo_existe
	sb $t0 jugador_disparo_mover
	beqz $t1 Main_win # Gano al matar a todos los invasores
	b fin_disparo_done
fin_disparo_done:
	li $t0 0
	sb $t0 jugador_disparo_existe
	sb $t0 jugador_disparo_mover
fin_disparo_return:
	jr $ra

####################################################
# Crea la matriz invasora
invasores:
	lb $a0 invasor_x
	lb $a1 invasor_y
	move $t0 $ra
	move $t1 $a0
	move $t2 $a1
	li $t3 0 # contador en x
	li $t4 0 # contador en y
	lb $t5 invasor_size_x
	lb $t6 invasor_size_y
	li $t7 0 # contador de bytes
	move $t9 $a0 #backup x	
in_c_loop:
	li $t3 0
	move $t1 $t9
	jal in_c_loop2_ra
	addi $t4 $t4 1
	addi $t2 $t2 2
	bne $t4 $t6 in_c_loop
	b in_v
in_c_loop2_ra:
	sw $ra ($sp)
in_c_loop2:
	move $a0 $t1 # x
	move $a1 $t2 # y
	jal DireccionEnMemoria
	sw $v0 invasor($t7)
	addi $t3 $t3 1
	addi $t1 $t1 2
	addi $t7 $t7 4
	bne $t3 $t5 in_c_loop2
	lw $ra ($sp)
	jr $ra
in_v:	li $t1 0
	li $t2 1
in_v_loop: # invasores vivos, un vector lleno de unos
	sb $t2 invasor_vivos($t1)
	addi $t1 $t1 1
	bne $t1 40 in_v_loop
in_c_done:
	jr $t0
	
##################################################
# Mostrar la matriz invasora en pantalla	
# No retorna nada
mostrar_invasores:
	li $t0 0 # contador de bytes
	lb $t1 invasor_size
	lw $t2 color_invasor
	li $t5 0 # contador
mostrar_invasores_loop:
	lb $t4 invasor_vivos($t5)
	beqz $t4 mostrar_invasor_muerto
	lw $t3 invasor($t0)
	sw $t2 ($t3)
	addi $t0 $t0 4
	addi $t5 $t5 1
	bne $t5 40 mostrar_invasores_loop
	b mostrar_invasores_return
mostrar_invasor_muerto:
	addi $t0 $t0 4
	addi $t5 $t5 1
	bne $t5 40 mostrar_invasores_loop
mostrar_invasores_return:
	jr $ra

##################################################
# Mover invasores	
# No retorna nada
mover_invasores:
	sw $ra ($sp)
	lb $t7 invasor_mover
	lb $t8 invasor_velocidad
	addi $t7 $t7 1
	sb $t7 invasor_mover
	bne $t7 $t8 mover_matriz_return
	li $t7 0
	jal limpiar_invasores
	sb $t7 invasor_mover
	lb $t0 invasor_x
	lb $t1 invasor_y
	beq $t1 21 Main_lose
	lb $t2 invasor_sentido
	lb $t5 invasor_size
	beqz $t2 mover_matriz_derecha
	
mover_matriz_izquierda:
	beq $t0 3 mover_matriz_abajo_d
	subi $t0 $t0 1
	sb $t0 invasor_x
	li $t3 0 # contador de bytes
	li $t4 0 # contador
mover_matriz_iloop:
	lw $t6 invasor($t3)
	subi $t6 $t6 4
	sw $t6 invasor($t3)
	addi $t3 $t3 4
	addi $t4 $t4 1
	bne $t4 $t5 mover_matriz_iloop
	j mover_matriz_return
	
mover_matriz_derecha:
	beq $t0 10 mover_matriz_abajo_i
	addi $t0 $t0 1
	sb $t0 invasor_x
	li $t3 0 # contador de bytes
	li $t4 0 # contador
mover_matriz_dloop:
	lw $t6 invasor($t3)
	addi $t6 $t6 4
	sw $t6 invasor($t3)
	addi $t3 $t3 4
	addi $t4 $t4 1
	bne $t4 $t5 mover_matriz_dloop
	j mover_matriz_return
	
mover_matriz_abajo_i:
	li $t2 1
	sb $t2 invasor_sentido
	b mover_matriz_abajo
mover_matriz_abajo_d:
	li $t2 0
	sb $t2 invasor_sentido
	b mover_matriz_abajo
	
mover_matriz_abajo:
	li $t3 0 # contador de bytes
	li $t4 0 # contador
	addi $t1 $t1 1
	sb $t1 invasor_y
mover_matriz_aloop:
	lw $t6 invasor($t3)
	addi $t6 $t6 128 # 32 x 4 = 128
	sw $t6 invasor($t3)
	addi $t3 $t3 4
	addi $t4 $t4 1
	bne $t4 $t5 mover_matriz_aloop
	# Al llegar la matriz a lo ultimo el borde cambia de color para avisar que es la ultima
	li $t0 20
	lb $t1 invasor_y
	beq $t1 $t0 mover_matriz_ultimo_color
	b mover_matriz_return
	
mover_matriz_ultimo_color:
	lw $t0 color_borde_ultima
	sw $t0 color_borde
	jal actualizar_borde
	
mover_matriz_return:
	jal mostrar_invasores
	lw $ra ($sp)
	jr $ra
	
##################################################
# Limpia los invasores en la patalla
limpiar_invasores:
	li $t0 0 #contador bytes
	lb $t1 invasor_size
	lw $t2 color_fondo
	li $t4 0 # contador
limpiar_invasores_loop:
	lw $t3 invasor($t0)
	sw $t2 ($t3)
	addi $t0 $t0 4
	addi $t4 $t4 1
	bne $t4 $t1 limpiar_invasores_loop
	jr $ra

####################################################
# Crea la forma del jugador y lo guarda en un vector
player:	move $t0 $ra
	lb $a0 jugador_x
	li $t1 29
	lw $t2 color_jugador
pl_c:	move $a1 $t1
	jal DireccionEnMemoria
	li $t3 0
	sw $v0 jugador($t3) # pixel centro
	addi $v0 $v0 -4
	addi $t3 $t3 4
	sw $v0 jugador($t3) # pixel izquierda
	addi $v0 $v0 8
	addi $t3 $t3 4
	sw $v0 jugador($t3) # pixel derecho
	li $a1 28
	jal DireccionEnMemoria
	addi $t3 $t3 4
	sw $v0 jugador($t3)
	jr $t0

##################################################
# Mostrar el vector jugador en pantalla	
# No retorna nada
mostrar_jugador:
	li $t0 0
	lb $t1 jugador_size
	lw $t2 color_jugador
mostrar_jugador_loop:
	lw $t3 jugador($t0)
	sw $t2 ($t3)
	addi $t0 $t0 4
	bne $t0 $t1 mostrar_jugador_loop
	jr $ra
	
##################################################
# Limpia el jugador en la patalla
# No retorna nada
limpiar_jugador:
	li $t0 0
	lb $t1 jugador_size
	lw $t2 color_fondo
limpiar_jugador_loop:
	lw $t3 jugador($t0)
	sw $t2 ($t3)
	addi $t0 $t0 4
	bne $t0 $t1 limpiar_jugador_loop
	jr $ra
	
##################################################
# Mover Jugador izquierda
# No retorna nada
mover_jugador_i:
	li $t0 0
	lb $t1 jugador_size
mover_jugador_loop_i:
	lw $t2 jugador($t0)
	lb $t3 jugador_x
	beq $t3 3 mover_jugador_i_sin_accion
	subi $t2 $t2 4
	sw $t2 jugador($t0)
	addi $t0 $t0 4
	bne $t0 $t1 mover_jugador_loop_i
	subi $t3 $t3 1
	sb $t3 jugador_x
mover_jugador_i_sin_accion:
	jr $ra
	
##################################################
# Mover Jugador derecha
# No retorna nada
mover_jugador_d:
	li $t0 0
	lb $t1 jugador_size
mover_jugador_loop_d:
	lw $t2 jugador($t0)
	lb $t3 jugador_x
	beq $t3 28 mover_jugador_d_sin_accion
	addi $t2 $t2 4
	sw $t2 jugador($t0)
	addi $t0 $t0 4
	bne $t0 $t1 mover_jugador_loop_d
	addi $t3 $t3 1
	sb $t3 jugador_x
mover_jugador_d_sin_accion:
	jr $ra

####################################################
# Crea el disparo generado por el jugador
invasor_disparo:
	sw $ra ($sp)
	lb $t2 invasor_disparo_existe
	bnez $t2 invasor_disparo_return
	lb $t3 invasor_x
	li $t4 20
	random_int($t4)
	add $a0 $t3 $a0
	lb $a1 invasor_y
	jal DireccionEnMemoria
	sw $v0 invasor_disparo_data
	li $t1 1
	sb $t1 invasor_disparo_existe
invasor_disparo_return:
	lw $ra ($sp)
	jr $ra

####################################################
# Mover disparo del jugador hacia arriba
invasor_mover_disparo:
	sw $ra ($sp)
	lb $t2 invasor_disparo_existe
	beqz $t2 invasor_disparo_return 
	lb $t1 invasor_disparo_mover
	lb $t2 invasor_disparo_velocidad
	addi $t1 $t1 1
	sb $t1 invasor_disparo_mover
	bne $t1 $t2 invasor_mover_disparo_return
	jal invasor_limpiar_disparo
	jal invasor_fin_disparo
	li $t1 0
	sb $t1 invasor_disparo_mover
	lw $t0 invasor_disparo_data
	addi $t0 $t0 128
	sw $t0 invasor_disparo_data
	jal invasor_mostrar_disparo
invasor_mover_disparo_return:
	lw $ra ($sp)
	jr $ra
	
####################################################
# Fin disparo. Cuando el disparo llega a su fin. 
# Puede llegar al borde o a un invasor
invasor_fin_disparo:
	move $t7 $ra
	lw $t0 invasor_disparo_data
	move $t1 $t0
	addi $t1 $t1 128
	bge $t1 0x10008F80 invasor_fin_disparo_done # llego a la ultima fila. 31 x 31 x 4 = 0x10008F80
	lw $t2 ($t1)
	lw $t3 color_fondo
	lw $t4 color_invasor
	lw $t5 color_disparo
	beq $t5 $t2 invasor_fin_disparo_done # cuando los dos disparos chocan
	beq $t4 $t2 invasor_fin_disparo_return
	bne $t2 $t3 fin_disparo_a_jugador
	b invasor_fin_disparo_return
fin_disparo_a_jugador:
	lb $t0 jugador_vidas
	subi $t0 $t0 1
	beqz $t0 Main_lose
	sb $t0 jugador_vidas
	jal actualizar_borde
fin_disparo_a_jugador_eliminar_vida:
	li $t0 0
	lw $t9 color_jugador
	lw $t2 color_invasor_disparo
	sw $t2 color_jugador
	jal mostrar_jugador
	sw $t9 color_jugador
	li $t8 500
	sleep($t8)
	lb $t0 jugador_vidas
	beqz $t0 Main_lose
invasor_fin_disparo_done:
	li $t0 0
	sb $t0 invasor_disparo_existe
	sb $t0 invasor_disparo_mover
invasor_fin_disparo_return:
	jr $t7

####################################################
# Limpia el disparo.
invasor_limpiar_disparo:
	lw $t0 invasor_disparo_data
	lw $t1 color_fondo
	sw $t1 0($t0)
	jr $ra

####################################################
# Muestra el disparo del invasor
invasor_mostrar_disparo:
	lw $t0 invasor_disparo_data
	lw $t1 color_invasor_disparo
	sw $t1 ($t0)
	jr $ra

##################################################
# Funcion que retorna el valor de la tecla presionada
# Esta subrutina fue gracias a: https://dtconfect.wordpress.com/projects/year2/mips-snake-and-primlib/
# Retorna v0 = direccion
Obtener_tecla:
	lw $t0 0xFFFF0004		# Carga el valor presionado (ASCII)
Obtener_tecla_derecha:
	bne $t0 100 Obtener_tecla_izquierda
	li $v0 0x01000000
	j Obtener_tecla_return
Obtener_tecla_izquierda:
	bne $t0 97 Obtener_tecla_disparo
	li $v0 0x02000000
	j Obtener_tecla_return
Obtener_tecla_disparo:
	bne $t0 32 Obtener_tecla_return
	li $v0 0x03000000		
Obtener_tecla_return:
	jr $ra
	
##################################################
# Reiniciar juego
reiniciar:
	li $t0 16
	sb $t0 jugador_x
	li $t0 40
	sb $t0 invasor_vivos_contador
	li $t0 3
	sb $t0 invasor_x
	li $t0 2
	sb $t0 invasor_y
	li $t0 0
	sb $t0 invasor_sentido
	li $t0 12
	sw $t0 invasor_velocidad
	li $t0 0
	sb $t0 invasor_disparo_existe
	sb $t0 invasor_disparo_mover
	sb $t0 invasor_mover
	sb $t0 jugador_disparo_existe
	sb $t0 jugador_disparo_mover
	li $t0 0x0000FF00
	sw $t0 color_invasor
	li $t0 0x00228b22
	sw $t0 color_borde 
	li $t0 1
	sb $t0 niveles
	li $t0 3
	sb $t0 jugador_vidas
	j Main_iniciar
	
##################################################
# Siguiente Nivel.
# - Aumenta la velocidad de los invasores
# - Se dejan las vidas anteriores
siguiente_nivel:
	lb $t0 niveles
	addi $t0 $t0 1
	sb $t0 niveles
	beq $t0 2 siguiente_nivel_2
	j siguiente_nivel_3
siguiente_nivel_2:
	lw $t0 color_invasor_nivel_2
	sw $t0 color_invasor
	lb $t0 invasor_velocidad
	subi $t0 $t0 2
	sb $t0 invasor_velocidad
	j siguiente_nivel_reiniciar
siguiente_nivel_3:
	lw $t0 color_invasor_nivel_3
	sw $t0 color_invasor
	lb $t0 invasor_velocidad
	subi $t0 $t0 1
	sb $t0 invasor_velocidad
siguiente_nivel_reiniciar:
	li $t0 16
	sb $t0 jugador_x
	li $t0 40
	sb $t0 invasor_vivos_contador
	li $t0 3
	sb $t0 invasor_x
	li $t0 2
	sb $t0 invasor_y
	li $t0 0
	sb $t0 invasor_sentido
	li $t0 0
	sb $t0 invasor_disparo_existe
	sb $t0 invasor_disparo_mover
	sb $t0 invasor_mover
	li $t0 0x00228b22
	sw $t0 color_borde 
	j Main_iniciar