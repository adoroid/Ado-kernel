#!/bin/sh

# ready zImage
rm zImage
#rm kernel.elf
rm boot.img
rm ramdisk.img
cp kernel/arch/arm/boot/zImage zImage

# lib copy
cp -P ./kernel/net/compat-wireless/drivers/staging/cw1200/cw1200_core.ko ./ramdisk/lib/modules/3.0.8+/kernel/net/compat-wireless/drivers/staging/cw1200/
cp -P ./kernel/net/compat-wireless/drivers/staging/cw1200/cw1200_wlan.ko ./ramdisk/lib/modules/3.0.8+/kernel/net/compat-wireless/drivers/staging/cw1200/

# remove debug code
${CROSS_COMPILE}strip -g --strip-unneeded ./ramdisk/lib/modules/3.0.8+/kernel/net/compat-wireless/drivers/staging/cw1200/cw1200_core.ko
${CROSS_COMPILE}strip -g --strip-unneeded ./ramdisk/lib/modules/3.0.8+/kernel/net/compat-wireless/drivers/staging/cw1200/cw1200_wlan.ko

# make ramdisk image
cd ramdisk
find . | cpio --quiet -H newc -o | gzip > ../ramdisk.img
cd ..

# make kernel
./mkbootimg --cmdline 'cachepolicy=writealloc noinitrd init=init board_id=1 logo.nologo root=/dev/ram0 rw rootwait console=null androidboot.console=null androidboot.hardware=st-ericsson mem=96M@0 mem_mtrace=15M@96M mem_mshared=1M@111M mem_modem=16M@112M mem=32M@128M mem_issw=1M@160M hwmem=167M@161M mem=696M@328M vmalloc=384M mpcore_wdt.mpcore_margin=359' --kernel zImage --ramdisk ramdisk.img --base 0x0 --output boot.img

# make kernel
python mkelf.py -o kernel-unsigned.elf zImage@0x00008000 ramdisk.img@0x1000000,ramdisk cmdline.txt@cmdline
