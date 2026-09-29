obj-m += vfd_fix.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
	make -C $(KDIR) M=$(PWD) modules ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-

clean:
	make -C $(KDIR) M=$(PWD) clean
