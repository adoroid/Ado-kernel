cd kernel
make clean
make riogrande_nypon_defconfig
make -j4
cd ..
./makeit_p.sh
fastboot flash boot boot.img
