# Ricardo Rodríguez <ricardo96r@gmail.com>
# MACROS BASICOS UTILES
.macro print_str(%str)
	.data
string: .asciiz %str # AL USARLO SE CAMBIA A string_M1...string_M99999
	.text
	li $v0 4
	la $a0 string
	syscall
.end_macro

.macro print_char(%char)
	li $v0 11
	add $a0 $zero %char
	syscall
.end_macro

.macro print_int(%int)
	li $v0 1
	add $a0 $zero %int
	syscall
.end_macro

.macro print_binary(%int)
	li $v0 35
	add $a0 $zero %int
	syscall
.end_macro

.macro print_hex(%int)
	li $v0 34
	add $a0 $zero %int
	syscall
.end_macro

.macro read_int(%save)
	li $v0 5
	syscall
	move %save $v0
.end_macro

.macro read_str(%vector, %size)
	li $v0 8
	la $a0 %vector
	li $a1 %size
	syscall
.end_macro

.macro read_char(%save)
	li $v0 12
	syscall
	move %save $v0
.end_macro

.macro exit()
	li $v0 10
	syscall
.end_macro

.macro exit (%termination_value)
	li $a0, %termination_value
	li $v0, 17
	syscall
.end_macro

.macro sleep (%milisegundos)
	li $v0 32 		# Syscall 32. Usa el Sleep de Java
	move $a0 %milisegundos
	syscall
.end_macro

.macro random_int (%hasta)
	li $v0 42 		# Random de java
	li $a0 0
	move $a1 %hasta
	syscall
.end_macro

