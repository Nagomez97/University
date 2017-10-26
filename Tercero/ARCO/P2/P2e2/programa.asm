.data 0
num0:  .word 1  # posic 0
num1:  .word 2  # posic 4
num2:  .word 4  # posic 8 
num3:  .word 8  # posic 12 
num4:  .word 16 # posic 16 
num5:  .word 32 # posic 20
num6:  .word 0  # posic 24
num7:  .word 0  # posic 28
num8:  .word 0  # posic 32
num9:  .word 0  # posic 36
num10: .word 0  # posic 40
num11: .word 0  # posic 44

.text 0
main:
  # carga num0 a num5 en los registros 9 a 14
  lw $t1, 0($zero)  # lw $r9,  0($r0)  -> r9  = 1
  lw $t2, 4($zero)  # lw $r10, 4($r0)  -> r10 = 2
  lw $t3, 8($zero)  # lw $r11, 8($r0)  -> r11 = 4 
  lw $t4, 12($zero) # lw $r12, 12($r0) -> r12 = 8 
  # Loads seguidos de un beq que no salta
  lw $t5, 16($zero) # lw $r13, 16($r0) -> r13 = 16. Adelantamiento desde registro
  lw $t6, 20($zero) # lw $r14, 20($r0) -> r14 = 32. Se va a hacer adelantamiento desde memoria(con bubble)
  beq $t5, $t6, next # no deberia saltar
  nop
  nop
  nop
  nop
  # Load seguido de un beq que salta
  lw $t7, 0($zero) # r15 = 1. Se va a hacer adelantamiento desde memoria(con bubble)
  beq $t7, $t7, next # deberia saltar a next
  nop
  nop
  nop
  nop
next:
  # Instruccion tipo R seguida de un beq que NO salta
  add $t1, $t2, $t2 # -> r9 = 4. Se va a hacer adelantamiento desde ejecucion
  beq $t1, $t2, jump # no deberia saltar
  # Estos and deberian ejecutarse
  and $t6, $t5, $t5 # -> r13 = 16
  and $t6, $t4, $t4 # -> r13 = 8
  and $t6, $t5, $t5 # -> r13 = 16
  # Instruccion tipo R seguida de un beq que SI salta
  and $t2, $t4, $t4 # -> r13 = 8
  beq $t2, $t2, jump # -> salta a jump
  # Esto no deberia ejecutarse
  and $t6, $t2, $t2 # -> r13 = 2
  and $t2, $t1, $t1 # -> r10 = 1
  nop
  nop
  nop
  nop
jump:
  and $t7, $t4, $t4 # -> r14 = 8