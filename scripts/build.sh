#!/bin/bash

KERNEL_VERSION=6.4
BUSYBOX_VERSION=1.35.0
KERNEL_MAJOR=$(echo $KERNEL_VERSION | sed 's/\([0-9]*\)[^0-9].*/\1/')
VERSION=0.1

#Build kernel and busybox
[ -d "src" ] || mkdir "src"
cd src
	#Download Kernel
	echo "[Linux $KERNEL_VERSION] Downloading"
	if [ -f "linux-$KERNEL_VERSION.tar.xz" ]; then
		echo "[Linux $KERNEL_VERSION] File already exist. Jumping to compile..."
	else
		wget --quiet --show-progress https://mirrors.edge.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR.x/linux-$KERNEL_VERSION.tar.xz
		tar -xf linux-$KERNEL_VERSION.tar.xz
	fi

	#Download BusyBox
	echo "[Busybox $BUSYBOX_VERSION] Downloading"
	if [ -f "busybox-$BUSYBOX_VERSION.tar.bz2" ]; then
		echo "[Busybox $BUSYBOX_VERSION] File already exist. Jumping to compile..."
	else
		wget --quiet --show-progress https://www.busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
		tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
	fi

	#Compile Kernel
	echo "[MinSys $VERSION] Compiling kernel $KERNEL_VERSION"
	cd linux-$KERNEL_VERSION
		make -s defconfig
		make -s -j8 || exit
	cd ..
	echo "[Linux $KERNEL_VERSION] Compile done"

	#Compile BusyBox
	echo "[MinSys $VERSION] Compiling BusyBox $BUSYBOX_VERSION"
	cd busybox-$BUSYBOX_VERSION
		make -s defconfig
		sed 's/^.*CONFIG_STATIC[^_].*$/CONFIG_STATIC=y/g' -i .config
		make -s CC=musl-gcc -j8 busybox || exit
	cd ..
	echo "[Busybox $BUSYBOX_VERSION] Compile done"

cd ..

# Creating filesystem
echo "[MinSys $VERSION] Creating Filesystem"
cp src/linux-$KERNEL_VERSION/arch/x86_64/boot/bzImage .
mkdir initrd
cd initrd

	mkdir -p bin dev proc sys home etc/minsys
	cd bin
		cp ../../src/busybox-$BUSYBOX_VERSION/busybox ./

		for prog in $(./busybox --list); do
			ln -s /bin/busybox ./$prog
		done
	cd ..

	#Creating base files
	echo '#!/bin/sh' > init
	echo 'mount -t systs sysfs /sys' >> init
	echo 'mount -t proc proc /proc' >> init
	echo 'mount -t devtmpfs udev /dev' >> init
	echo 'sysctl -w kernel.printk="2 4 1 7"' >> init

	#Adding poweroff
	echo -n `echo '#!/bin/sh' > bin/shutdown` >> init
	echo -n `echo 'poweroff -f' >> bin/shutdown` >> init

    # MinSys logo
    cp ../assets/logo_ascii etc/minsys/logo_ascii
    echo '/bin/cat /etc/minsys/logo_ascii; /bin/echo' >> init

    # Create users
    echo -n `echo '' >> etc/group` >> init
    echo `echo 'root:x:0:0::/root:/bin/sh' >> etc/passwd` >> init

    echo '/bin/sh' >> init
    echo 'poweroff -f' >> init
    find . -type d -name "etc" -prune -o -type f -exec chmod 777 {} +
    find . | cpio -o -H newc > ../MinSys$VERSION.img

cd ..

echo "[MinSys $VERSION] Everything is done, exiting"
