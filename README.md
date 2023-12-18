# Niski

This system combines several university assignments into a functional whole project. 
It integrates FPGA design, low-level programming, and system programming. 
The ultimate objective of this project is to develop a programmable microcontroller 
capable of running any multithreaded program while also facilitating communication with the outside world."

## Hardware
For this project Cyclone IV EP4CE6E22C8 FPGA development board was used:
![FPGA Board](board.jpg)

It has the following features:
- 6,272 Logic Elements
- 276,480 Total RAM Bits
- 30 Embedded 9 x 9 Multipliers
- 2 PLLs
- 92 I/O Pins
- 50 MHz Clock

The development board has the following peripherals:
- 4 LEDs
- 4 seven-segment displays
- 4 buttons
- buzzer
- 16x2 LCD display
- VGA port
- PS/2 port
- UART port

### CPU
Initially, I had a desire to create my own processor with custom instructions. 
However, I soon recognized the advantages of utilizing a standardized architecture 
for which compilers for higher-level programming languages already exist. 
This realization led me to opt for RISC-V, a versatile architecture that permits 
the addition of extensions.

I specifically selected the 32-bit version due to limited available memory, 
which will never exceed 4GB.
Currently, the processor partially supports the M extension, 
providing hardware multiplication capabilities, while division operations 
rely on the GCC library.
To ensure seamless compatibility with operating systems, the Zicsr extension 
was also essential, and I successfully implemented it."

Because of the above, the current name of the architecture is **RV32EMZicsr**.
![FPGA Board](riscv.png)

### Memory
The processor features a 32-bit address bus, allowing it to 
potentially address up to 4GB of memory. 
However, due to the limited resources of the FPGA development board, 
only 64KB of memory is currently available, which is constructed 
using the onboard Block RAM resources. 
In the future, I plan to explore adding support for SDRAM memory, 
which is available on the development board. 
This upgrade would extend the accessible memory to 8MB.

### Peripherals
On the FPGA development board, there are several
peripherals that can be used by the processor.
For every peripheral, a controller and memory-mapped
bus interface was designed.

### DMA
In order to facilitate efficient data transfer, 
I have implemented a DMA (Direct Memory Access) controller. 
This controller offers flexibility in handling both source 
and destination addresses, allowing for incrementing, decrementing,
or fixed addressing modes. 
Additionally, data transfers can occur in either burst mode 
(single bus request for the entire transfer) or normal mode 
(a bus request for every byte).

Currently, the DMA operation isn't as efficient as it could be, 
as it reads/writes only one byte per bus request. 
In my future plans, I intend to enhance the efficiency 
by enabling the controller to read/write 4 bytes at a time.

### Watchdog
To prevent the processor from becoming stuck 
in an infinite loop when encountering an invalid address 
(one not associated with any module or memory-mapped register), 
a watchdog timer has been implemented. 
This timer generates a signal to halt the ongoing request 
and trigger an exception on the processor.

## Software
A small yet functional operating system kernel is in place, 
aiming to adhere to the C23 language standard. 
In addition to its core functionality, 
the kernel includes functions to facilitate communication 
with external devices on the FPGA development board.

Dynamic memory allocation for user programs is achieved 
using a first-fit algorithm, while a more efficient 
buddy/slab algorithm is employed for kernel objects.

The kernel offers support for multithreading, 
although multiprocessing is not currently supported. 
The scheduler operates on a FIFO basis, but I have plans 
to implement a more efficient scheduling algorithm in the future. 
The scheduling is preemptive, with a time slice set to 1 second.

### C standard library
GCC automatically generates header files containing types 
and other definitions that are architecture-dependent 
rather than tied to the specific operating system

Therefore, following header files already exist:
- __stddef.h__
- __stdint.h__
- __stdbool.h__
- __ctype.h__

The OS developer is responsible for implementing additional header files. 
Some functions will be designed as system calls, 
while others will function as library functions. 
Currently, the following header files and functions have been fully implemented:
- __errno.h__
- __stdlib.h__
	- `malloc`
	- `calloc`
	- `free`
- __stdio.h__
	- `putchar`
	- `puts`
- __threads.h__
	- `thrd_create`
	- `thrd_equal`
	- `thrd_current`
	- `thrd_yield`
	- `thrd_exit`
	- `mtx_init`
	- `mtx_lock`
	- `mtx_unlock`
	- `mtx_destroy`
	- `cnd_init`
	- `cnd_signal`
	- `cnd_broadcast`
	- `cnd_wait`
	- `cnd_destroy`
- __time.h__
	- `difftime`
	- `time`
	- `clock`
	- `timespec_get`
	- `timespec_getres`
- __string.h__
	- `strcpy`
	- `strncpy`
	- `strcat`
	- `strncat`
	- `strdup`
	- `strndup`
	- `strlen`
	- `strcmp`
	- `strncmp`
	- `strchr`
	- `strrchr`
	- `strstr`
	- `strtok`
	- `memchr`
	- `memcmp`
	- `memset`
	- `memset_explicit`
	- `memcpy`
	- `memccpy`
	- `memmove`

### I/O devices
In order to facilitate communication with external devices 
on the FPGA development board (such as the buzzer, LEDs, 
7-segment displays, LCD, etc.), drivers are essential. 
At present, the following header files and functions have been fully implemented:
- __devices/buzzer.h__
	- `buzzer_on`
	- `buzzer_off`
	- `buzzer_set`
	- `buzzer_toggle`
- __devices/leds.h__
	- `leds_on`
	- `leds_off`
	- `leds_set_single`
	- `leds_toggle_single`
	- `leds_set`
- __devices/ssds.h__
	- `ssds_on`
	- `ssds_off`
	- `ssds_set`
	- `ssds_set_dots`
	- `ssds_set_digit`
	- `ssds_set_dec_num`
	- `ssds_set_hex_num`
- __devices/lcd.h__
	- `lcd_init`
	- `lcd_clear`
	- `lcd_move_cursor`
	- `lcd_send_cmd`
	- `lcd_write_ch`
- __devices/dma.h__
	- `dma_transfer`
	- `dma_fill`
	- `dma_copy`
	- `dma_rcopy`
- __devices/btns.h__
	- `btns_enable_single`
	- `btns_disable_single`
	- `btns_enable_all`
	- `btns_disable_all`
	- `btns_get_statuses`
	- `btns_is_pressed`
	- `btns_on_1_pressed` *(weak)*
	- `btns_on_2_pressed` *(weak)*
	- `btns_on_3_pressed` *(weak)*
	- `btns_on_4_pressed` *(weak)*
	