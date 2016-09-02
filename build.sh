#!/bin/bash

PARENT=`readlink -f .`
INSTALLER=$PARENT/compiled
VER="1.25.0"

echo " "
echo "**************************************************************"
echo "**************************************************************"
echo "               Cleaning Up Old Compiled Files                 "
echo "**************************************************************"
echo "**************************************************************"
echo " "

make mrproper
make clean

if [ -e $PARENT/compiled/busybox ]; then
	echo "  CLEAN   busybox"
	rm $PARENT/compiled/busybox
fi
if [ -e $PARENT/compiled/busybox-$VER.zip ]; then
	echo "  CLEAN   busybox-$VER.zip"
	rm $PARENT/compiled/busybox-$VER.zip
fi

echo " "
echo "**************************************************************"
echo "**************************************************************"
echo "               Setting Up Configuration Files                 "
echo "**************************************************************"
echo "**************************************************************"
echo " "

COMPILE="arm-linux-gnueabi-"

make nega_defconfig

echo "         ______                   _       _                   "
echo "        |  ___ \                 | |     (_)_                 "
echo "        | |   | | ____ ____  ____| |      _| |_  ____         "
echo "        | |   | |/ _  ) _  |/ _  | |     | |  _)/ _  )        "
echo "        | |   | ( (/ ( ( | ( ( | | |_____| | |_( (/ /         "
echo "        |_|   |_|\____)_|| |\_||_|_______)_|\___)____)        "
echo "                     (_____|                                  "
echo " "
echo "**************************************************************"
echo "**************************************************************"

# Start Timer
TIME1=$(date +%s)

function progress(){
echo -n "Please wait..."
while true
do
     echo -n "."
     sleep 5
done
}

function compile(){
	
	make -j`grep 'processor' /proc/cpuinfo | wc -l` busybox ARCH=arm CROSS_COMPILE=$COMPILE LDFLAGS="-static" CFLAGS="-static" V=s 2>&1 | tee build.log | grep -e Error
	
	if [ -e $PARENT/busybox ]; then
		echo " "
		echo "**************************************************************"
		echo "**************************************************************"
		echo "                      Busybox Compiled!!!                     "
		echo "**************************************************************"
		echo "**************************************************************"
		echo " "
		
		cp $PARENT/busybox $PARENT/compiled/busybox
		
		echo " "
		echo "**************************************************************"
		echo "**************************************************************"
		echo "          Zipping Busybox Up For Flashable Package            "
		echo "**************************************************************"
		echo "**************************************************************"
		echo " "
		
		cd $INSTALLER

		zip -9 -r busybox-flash META-INF busybox
		mv $INSTALLER/busybox-flash.zip $INSTALLER/busybox-$VER.zip
		
		echo " "
		echo "**************************************************************"
		echo "**************************************************************"
		echo "              Compile finished Successfully!!!                "
		echo "**************************************************************"
		echo "**************************************************************"
		echo " "
	else
		echo " "
		echo "**************************************************************"
		echo "**************************************************************"
		echo "       Something went wrong, busybox did not build...         "
		echo "**************************************************************"
		echo "**************************************************************"
		echo " "
	fi;	
}

# Start progress bar in the background
progress &
# Start backup
compile

# End Timer, GetResult
TIME2=$(date +%s)
DIFFSEC="$(expr $TIME2 - $TIME1)"

echo "**************************************************************"
echo "**************************************************************"
echo | awk -v D=$DIFFSEC '{printf "                   Compile time: %02d:%02d:%02d\n",D/(60*60),D%(60*60)/60,D%60}'
echo "**************************************************************"
echo "**************************************************************"
echo " "

# Kill progress
kill $! 1>&1
