.global get_cpu_inst_count

.text
get_cpu_inst_count:
	rdinstreth a1
	rdinstret a0
	ret