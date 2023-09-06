.global get_cpu_cycles
.global get_cpu_seconds
.global get_cpu_inst_count

.text

get_cpu_cycles:
	rdcycleh a1
	rdcycle a0
	ret

get_cpu_seconds:
	rdtimeh a1
	rdtime a0
	ret

get_cpu_inst_count:
	rdinstreth a1
	rdinstret a0
	ret