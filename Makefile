# Makefile for VFD Display Kernel Module
# 
# Usage:
#   make              - build the module
#   make clean        - remove compiled files
#   make load         - insmod the module
#   make unload       - rmmod the module
#   make install      - copy to /lib/modules/

obj-m += vfd_display.o

KERNEL_DIR ?= /lib/modules/$(shell uname -r)/build

all:
	@echo "Building VFD Display Module..."
	make -C $(KERNEL_DIR) M=$(PWD) modules
	@echo "Build complete!"

clean:
	@echo "Cleaning build files..."
	make -C $(KERNEL_DIR) M=$(PWD) clean
	@echo "Clean complete!"

load: all
	@echo "Loading VFD Display Module..."
	sudo insmod vfd_display.ko
	@echo "Module loaded! Test with:"
	@echo "  echo 'TEST' > /sys/kernel/vfd_display/display"

unload:
	@echo "Unloading VFD Display Module..."
	sudo rmmod vfd_display
	@echo "Module unloaded!"

reload: unload load

test: load
	@echo "Testing VFD Display..."
	@echo "TEST" | sudo tee /sys/kernel/vfd_display/display
	@sleep 1
	@echo "1234" | sudo tee /sys/kernel/vfd_display/display
	@sleep 1
	@echo "BOOT" | sudo tee /sys/kernel/vfd_display/display
	@sleep 1
	@echo "HI  " | sudo tee /sys/kernel/vfd_display/display
	@echo "Test complete!"

status:
	@echo "Checking module status..."
	@lsmod | grep vfd_display || echo "Module not loaded"
	@ls -la /sys/kernel/vfd_display/ 2>/dev/null || echo "sysfs not available"

help:
	@echo "VFD Display Module Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make              - Compile the module"
	@echo "  make clean        - Remove compiled files"
	@echo "  make load         - Compile and load module"
	@echo "  make unload       - Unload module"
	@echo "  make reload       - Reload module"
	@echo "  make test         - Load and run basic tests"
	@echo "  make status       - Check if module is loaded"
	@echo "  make help         - Show this help"

.PHONY: all clean load unload reload test status help
