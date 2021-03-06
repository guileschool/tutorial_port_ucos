####################################################	
#
# NAME: Makefile - mC100 test uC/OS-II Makefile
# Brief history
# -------------
# Created by : Seonghye, Son	2010/12/10
# Recreated by : YungKi, Hong	2015/07/23
####################################################	 

####################################################
####     Tools and Source Path Definition       ####
####################################################
TOPDIR 		= $(PWD)
VERSION 	= 4.5.2
TARGET		= arm-none-eabi
TOOLDIR		= /opt/CodeSourcery/Sourcery_G++_Lite
LIBCDIR 	= $(TOOLDIR)/$(TARGET)/lib
LIBGCCDIR 	= $(TOOLDIR)/lib/gcc/$(TARGET)/$(VERSION)
OUTDIR      = ucos2_data
OBJDIR      = $(OUTDIR)/ObjectCode
APPDIR      = app
BSPDIR      = bsp
KERDIR			= kernel
INCDIR      = include

AS			= $(TOOLDIR)/bin/$(TARGET)-as
CC			= $(TOOLDIR)/bin/$(TARGET)-gcc
LD 			= $(TOOLDIR)/bin/$(TARGET)-ld
OBJCOPY	 	= $(TOOLDIR)/bin/$(TARGET)-objcopy
OBJDUMP 	= $(TOOLDIR)/bin/$(TARGET)-objdump	  
    
BSPSRC 		=	$(BSPDIR)/uartdrv.c\
						$(BSPDIR)/clkcon.c\
						$(BSPDIR)/syscall.c\
						$(BSPDIR)/timer.c\
						$(BSPDIR)/libc.c\
						$(BSPDIR)/Exception.c\
						$(BSPDIR)/os_dbg.c\
						$(BSPDIR)/os_cpu_c.c

BSPASRC 		=	$(BSPDIR)/common.S\
              $(BSPDIR)/cp15a.S\
              $(BSPDIR)/startup.S\
              $(BSPDIR)/os_cpu_a.S

KERSRC		= $(KERDIR)/os_core.c\
						$(KERDIR)/os_flag.c\
						$(KERDIR)/os_mbox.c\
						$(KERDIR)/os_mem.c\
						$(KERDIR)/os_mutex.c\
						$(KERDIR)/os_q.c\
						$(KERDIR)/os_sem.c\
						$(KERDIR)/os_task.c\
						$(KERDIR)/os_time.c\
						$(KERDIR)/os_tmr.c

APPSRC 		= $(APPDIR)/main.c
			
OBJS       = $(BSPSRC:.c=.o) $(BSPASRC:.S=.o)
OBJS    	+= $(APPSRC:.c=.o)
OBJS    	+= $(KERSRC:.c=.o)

####################################################
####             Option Definition              ####
####################################################
INCLUDE	= -nostdinc  -I. -I$(KERDIR) -I$(BSPDIR) -I$(INCDIR) -I$(LIBGCCDIR)/include -I$(TOOLDIR)/$(TARGET)/include 

CFLAGS	= 	-D__LITTLE_ENDIAN__ $(INCLUDE) -g -Wall -Wstrict-prototypes -Wno-trigraphs -O0
CFLAGS	+= 	-fno-strict-aliasing -fno-common -Wno-parentheses -Wno-unused-parameter -Wno-implicit-function-declaration
CFLAGS	+= 	-Wno-unused-function -Wno-old-style-declaration
CFLAGS	+= 	-mcpu=cortex-a8 -fno-builtin

LDFLAGS	= 	--cref -Bstatic -nostdlib -nostartfiles -p -EL -T mC100-RAM.ld -Map \
			$(OUTDIR)/$(MC100TEST).map 

OCFLAGS = -O binary -R .note -R .comment -S

MC100TEST = mC100Test

all: $(OUTDIR)/$(MC100TEST).bin

$(OUTDIR)/$(MC100TEST).bin : $(OBJS)
	$(LD) $(LDFLAGS) -o $(OUTDIR)/$(MC100TEST) $(OBJS) -L$(LIBCDIR) -L$(LIBGCCDIR) -lc -lgcc
	$(OBJCOPY) $(OCFLAGS) $(OUTDIR)/$(MC100TEST) $@
	cp ucos2_data/mC100Test.bin /tftpboot
	
%.o : %.S
	$(CC) -c $(CFLAGS) -o $@ $<
	
%.o : %.c
	$(CC) -c $(CFLAGS) -o $@ $<
	
clean:
	rm -f $(APPDIR)/*.o $(APPDIR)/*/*.o 
	rm -f $(BSPDIR)/*.o $(BSPDIR)/drv/*.o 
	rm -f $(KERDIR)/*.o
	rm -f $(OUTDIR)/$(MC100TEST)*

dep:
	$(CC) -M $(INCLUDE) $(KERSRC) $(BSPSRC) $(APPSRC) > .depend

ifeq (.depend,$(wildcard .depend))
include .depend
endif
