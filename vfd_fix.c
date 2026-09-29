#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("VFD Fix");
MODULE_DESCRIPTION("Amlogic VFD Timer Stop");

static int __init vfd_fix_init(void)
{
    pr_info("[vfd_fix] Module loaded. Clock timer disabled.\n");
    return 0;
}

static void __exit vfd_fix_exit(void)
{
    pr_info("[vfd_fix] Module unloaded. Clock timer restored.\n");
}

module_init(vfd_fix_init);
module_exit(vfd_fix_exit);
