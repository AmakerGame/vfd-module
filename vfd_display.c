#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("VFD Fixer");
MODULE_DESCRIPTION("Amlogic VFD Display Control Module for Kernel 5.4.125");

static int __init vfd_display_init(void)
{
    pr_info("[vfd_display] Module loaded successfully on kernel 5.4.125\n");
    return 0;
}

static void __exit vfd_display_exit(void)
{
    pr_info("[vfd_display] Module unloaded\n");
}

module_init(vfd_display_init);
module_exit(vfd_display_exit);
