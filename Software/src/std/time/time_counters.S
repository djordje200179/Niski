.global time
.global clock

.text
time:
	mv a1, a0
	rdtime a0
	beq a1, zero, time_ret
	sw a0, 0(a1)
time_ret:
	ret

clock:
	rdcycleh a1
	rdcycle a0
	ret