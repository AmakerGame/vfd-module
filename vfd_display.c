/*
 * VFD Display Control Module
 * 
 * Exposes userspace API for Meson-VFD 4-char display control
 * No kernel modification required - just insmod this module
 * 
 * Usage:
 *   echo "TEXT" > /sys/kernel/vfd_display/display
 *   echo "1234" > /sys/kernel/vfd_display/display
 *   echo "BOOT" > /sys/kernel/vfd_display/display
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/kobject.h>
#include <linux/sysfs.h>
#include <linux/string.h>
#include <linux/slab.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("VFD Reverse Engineering");
MODULE_DESCRIPTION("Userspace VFD display control (Meson-VFD AArch64)");
MODULE_VERSION("1.0");

/* ============================================================================
 * KERNEL SYMBOL IMPORT - These are EXPORTED_SYMBOL from kernel
 * ============================================================================ */

/* Main display function - converts ASCII to 7-segment and writes to controller
 * Parameters:
 *   text (x0) = pointer to 4-byte buffer with characters
 *   flag (w1) = control flag (typically 0)
 */
extern void set_vfd_led_value(const char *text, int flag);

/* Low-level display per-segment function
 * Parameters:
 *   segment_id (x0) = which segment (0-3)
 *   byte_value (w1) = 7-segment pattern byte
 *   flag (w2) = control flag
 */
extern void MDrv_TM1623_LED_DISP(int segment_id, unsigned char byte_value, int flag);

/* ============================================================================
 * SYSFS INTERFACE
 * ============================================================================ */

/* Storage for text to be displayed (persistent across calls) */
static char vfd_text[5] = {0};
static struct mutex vfd_lock;

/* Sysfs store function - receives data from: echo "TEXT" > /sys/kernel/vfd_display/display */
static ssize_t display_store(struct kobject *kobj,
                             struct kobj_attribute *attr,
                             const char *buf, size_t count)
{
    char temp[5];
    int i, len;

    if (!buf || count == 0)
        return -EINVAL;

    /* Maximum 4 characters for display */
    len = (count > 4) ? 4 : count;

    /* Remove trailing newline if present */
    if (len > 0 && buf[len-1] == '\n')
        len--;

    if (len == 0)
        return -EINVAL;

    /* Copy user input and pad with spaces to 4 characters */
    memset(temp, ' ', 4);
    memset(temp + 4, '\0', 1);
    
    for (i = 0; i < len && i < 4; i++)
        temp[i] = buf[i];

    temp[4] = '\0';

    /* Lock and store text */
    mutex_lock(&vfd_lock);
    strncpy(vfd_text, temp, 4);
    vfd_text[4] = '\0';
    
    /* Call kernel function to display text */
    pr_info("VFD Display: '%s'\n", vfd_text);
    set_vfd_led_value(vfd_text, 0);
    
    mutex_unlock(&vfd_lock);

    return count;
}

/* Sysfs show function - returns current display text when read */
static ssize_t display_show(struct kobject *kobj,
                            struct kobj_attribute *attr,
                            char *buf)
{
    ssize_t ret;

    mutex_lock(&vfd_lock);
    ret = sprintf(buf, "%s\n", vfd_text);
    mutex_unlock(&vfd_lock);

    return ret;
}

/* LED control attributes */
static ssize_t greenled_store(struct kobject *kobj,
                              struct kobj_attribute *attr,
                              const char *buf, size_t count);

static ssize_t greenled_show(struct kobject *kobj,
                             struct kobj_attribute *attr,
                             char *buf);

/* Define sysfs attributes */
static struct kobj_attribute display_attr = __ATTR(display, 0644, display_show, display_store);

/* ============================================================================
 * MODULE INITIALIZATION & CLEANUP
 * ============================================================================ */

static struct kobject *vfd_kobj = NULL;

static int __init vfd_display_init(void)
{
    int ret = 0;

    pr_info("=== VFD Display Module Loading ===\n");
    pr_info("Kernel function set_vfd_led_value: %p\n", (void*)set_vfd_led_value);
    pr_info("Kernel function MDrv_TM1623_LED_DISP: %p\n", (void*)MDrv_TM1623_LED_DISP);

    /* Initialize mutex */
    mutex_init(&vfd_lock);

    /* Create /sys/kernel/vfd_display directory */
    vfd_kobj = kobject_create_and_add("vfd_display", kernel_kobj);
    if (!vfd_kobj) {
        pr_err("Failed to create kobject\n");
        return -ENOMEM;
    }

    /* Create sysfs attributes */
    ret = sysfs_create_file(vfd_kobj, &display_attr.attr);
    if (ret) {
        pr_err("Failed to create display attribute\n");
        kobject_put(vfd_kobj);
        return ret;
    }

    pr_info("=== VFD Display Module Loaded Successfully ===\n");
    pr_info("Usage:\n");
    pr_info("  echo 'TEXT' > /sys/kernel/vfd_display/display\n");
    pr_info("  echo '1234' > /sys/kernel/vfd_display/display\n");
    pr_info("  echo 'BOOT' > /sys/kernel/vfd_display/display\n");
    pr_info("  cat /sys/kernel/vfd_display/display\n");

    return 0;
}

static void __exit vfd_display_exit(void)
{
    pr_info("VFD Display Module Unloading...\n");

    if (vfd_kobj) {
        sysfs_remove_file(vfd_kobj, &display_attr.attr);
        kobject_put(vfd_kobj);
    }

    pr_info("VFD Display Module Unloaded\n");
}

module_init(vfd_display_init);
module_exit(vfd_display_exit);
