#!/bin/bash
#wget https://ftpmirror.gnu.org/binutils/binutils-2.31.tar.bz2
#wget https://ftpmirror.gnu.org/glibc/glibc-2.28.tar.bz2
#wget https://ftpmirror.gnu.org/gcc/gcc-8.3.0/gcc-8.3.0.tar.gz
#wget https://ftpmirror.gnu.org/gcc/gcc-10.1.0/gcc-10.1.0.tar.gz
git clone --depth=1 https://github.com/raspberrypi/linux

tar xf binutils-2.31.tar.bz2
tar xf glibc-2.28.tar.bz2
tar xf gcc-8.3.0.tar.gz
tar xf gcc-10.1.0.tar.gz
rm *.tar.*
cd gcc-8.3.0
contrib/download_prerequisites
rm *.tar.*
cd ..
cd gcc-10.1.0
contrib/download_prerequisites
rm *.tar.*
cd ..
cd ..
sudo mkdir -p /opt/cross-pi-gcc
sudo chown $USER /opt/cross-pi-gcc
export PATH=/mnt/d/opt/cross-pi-gcc/bin:$PATH
cd ..
cd linux
KERNEL=kernel7
make ARCH=arm INSTALL_HDR_PATH=/mnt/d/opt/cross-pi-gcc/arm-linux-gnueabihf headers_install
cd ..
mkdir build-binutils && cd build-binutils
../binutils-2.31/configure --prefix=/mnt/d/opt/cross-pi-gcc --target=arm-linux-gnueabihf --with-arch=armv6 --with-fpu=vfp --with-float=hard --disable-multilib
make -j 8
make install
cd ..
mkdir build-gcc && cd build-gcc
../gcc-8.3.0/configure --prefix=/mnt/d/opt/cross-pi-gcc --target=arm-linux-gnueabihf --enable-languages=c,c++,fortran --with-arch=armv6 --with-fpu=vfp --with-float=hard --disable-multilib
make -j8 all-gcc
make install-gcc
cd ..
mkdir build-glibc && cd build-glibc
../glibc-2.28/configure --prefix=/mnt/d/opt/cross-pi-gcc/arm-linux-gnueabihf --build=$MACHTYPE --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --with-arch=armv6 --with-fpu=vfp --with-float=hard --with-headers=/opt/cross-pi-gcc/arm-linux-gnueabihf/include --disable-multilib libc_cv_forced_unwind=yes
make install-bootstrap-headers=yes install-headers
make -j8 csu/subdir_lib
install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross-pi-gcc/arm-linux-gnueabihf/lib
arm-linux-gnueabihf-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross-pi-gcc/arm-linux-gnueabihf/lib/libc.so
touch /opt/cross-pi-gcc/arm-linux-gnueabihf/include/gnu/stubs.h
cd ..
cd build-gcc
make -j8 all-target-libgcc
make install-target-libgcc
cd ..
cd build-glibc
make -j8
make install
cd ..
cd build-gcc
make -j8
make install
cd ..
