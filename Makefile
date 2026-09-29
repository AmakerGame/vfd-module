obj-m += vfd_fix.o

# Прибираємо x86-специфічні прапорці хоста, які ламають крос-компіляцію ARM64
KBUILD_CFLAGS := $(filter-out -mrecord-mcount,$(KBUILD_CFLAGS))

all:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
