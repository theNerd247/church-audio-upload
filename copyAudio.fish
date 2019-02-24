#!/usr/bin/env fish

echo "mount and copy the usb drive data"
mount -U 68D4-F9FC /mnt
#mount /dev/sdb1 /mnt

set usbDir usb/(date +%F)_raw

echo "copying usb data into " $usbDir
mkdir -p $usbDir
cp -v /mnt/MGP_REC/Untitled*.mp3 $usbDir
chown -R :data $usbDir

# get the latest file written on disk
set latestFile $usbDir/Untitled(ls $usbDir | sed -e 's/Untitled\([0-9]*\).mp3/\1/g' | sort -n | tail -n 1).mp3

echo "copying latest audio file as today"
cp -v -p $latestFile raw/(date +%F)_raw.mp3

# copy raw audio to new and upload it to the server as well
cp raw/(date +%F)_raw.mp3 ./new/
