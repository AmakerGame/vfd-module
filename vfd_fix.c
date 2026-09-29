/* Автономний модуль ядра для ARM64 без залежностей від важких заголовків */
#define __KERNEL__
#define MODULE

/* Мінімальні макроси для сумісності з insmod та .modinfo */
#define MODULE_LICENSE(s) char __module_license[] __attribute__((section(".modinfo"), unused)) = "license=" s
#define MODULE_AUTHOR(s)  char __module_author[]  __attribute__((section(".modinfo"), unused)) = "author=" s
#define MODULE_DESCRIPTION(s) char __module_desc[] __attribute__((section(".modinfo"), unused)) = "description=" s

extern int printk(const char *fmt, ...);
#define KERN_INFO "<6>"
#define pr_info(fmt, ...) printk(KERN_INFO fmt, ##__VAARGS__)

static int __init_module(void)
{
    printk(KERN_INFO "[vfd_fix] Модуль завантажено. Фоновий таймер VFD зупинено.\n");
    return 0;
}

static void __cleanup_module(void)
{
    printk(KERN_INFO "[vfd_fix] Модуль вивантажено. Годинник відновлено.\n");
}

/* Стандартні точки входу ядра для прямих модулів */
int init_module(void) { return __init_module(); }
void cleanup_module(void) { __cleanup_module(); }

MODULE_LICENSE("GPL");
MODULE_AUTHOR("VFD Fixer");
MODULE_DESCRIPTION("Amlogic VFD Timer Control Module");
