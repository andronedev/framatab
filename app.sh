#!/bin/sh
CURRENT_VERSION=1.0.0 # Use this as version number for the app if you don't have a version file

self_update() {
version="$(cat version | grep -o '[0-9]\.[0-9]\.[0-9]')"
# if version is empty, then it is the first time running
if [ -z "$version" ]; then
    echo $CURRENT_VERSION > version
fi
SCRIPTDIR=$(dirname $0)
latest=$(curl -s https://raw.githubusercontent.com/andronedev/framatab/master/version | grep -o '[0-9]\.[0-9]\.[0-9]')
if [ "$latest" != "$version" ]; then
    echo "New version available: $latest"
    echo "Updating..."
    curl -s https://raw.githubusercontent.com/andronedev/framatab/master/app.sh > /tmp/app.sh
    chmod +x /tmp/app.sh
    mv /tmp/app.sh $SCRIPTDIR/app.sh
    echo "Updated to $latest"
    # run the script again
    $SCRIPTDIR/app.sh $@
    exit 0
fi
}
self_update
# check if args are min 2
if [ $# -lt 1 ]; then
    echo "Usage: $0 <start|stop|reboot>"
    exit 1
fi

# connect to device through adb
adb devices

gallery_packageName="com.android.gallery3d"
if [ -z $(adb shell pm list packages | grep $gallery_packageName) ]; then
    echo "WARNING : Gallery app not found"
    # get the package used by default to launch images
    # get default app for images
    # try to launch it
    gallery_packageName=$(adb shell "cmd package resolve-activity -a android.intent.action.VIEW -d file:///sdcard/image.jpg -t image/jpeg")
    # regexp to get the package name (name=package)
    gallery_packageName=$(echo $gallery_packageName | sed -e 's/.*packageName=//' -e 's/ .*//')
    echo "Gallery app found : $gallery_packageName"
fi

# parse arg time to int (not check if it's a valid time/folder)
time=$(echo $2 | sed 's/[^0-9]*//g')
folder=$3

close_galleryapp() {
    # stop app
    adb shell am force-stop $gallery_packageName
    sleep 1
}
close_htmlviewer() {
    # stop app
    adb shell am force-stop com.android.htmlviewer
}
open_black() {
    # open html data
    # use the package name to open the html file with html viewer
    adb shell am start -n com.android.htmlviewer/com.android.htmlviewer.HTMLViewerActivity -d file:///sdcard/black.html
}
set_photo() {
  
    # get random image of the $folder folder only png, jpg, jpeg

    image_path=$(find $folder -type f -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | shuf -n 1)
    # convert to jpg (if not already)
    if [ ! -f $image_path.jpg ]; then
        rm -f ./image.jpg
        convert $image_path ./image.jpg
        image_path="./image.jpg"
    fi
    echo "image path : $image_path"
    adb shell rm sdcard/image.jpg
    adb push $image_path sdcard/image.jpg

}

#  COMMANDES :

if [ "$1" = "reboot" ]; then
    # reboot device
    adb reboot

fi

# if arg is stop then stop the app
if [ "$1" = "stop" ]; then
    # stop apps
    close_galleryapp
    close_htmlviewer

    # start system
    adb shell pm enable com.android.systemui

    adb shell am startservice -n com.android.systemui/.SystemUIService
    # enable auto shutdown screen
    adb shell svc power stayon false
    # stop screen
    adb shell input keyevent 26

    exit 0
fi

if [ $1 = "start" ]; then

    # if no time or folder then exit
    if [ -z $time ] || [ -z $folder ]; then
        echo "Usage: $0 start <time> <folder>"
        exit 1
    fi

    # disable sound
    adb shell input keyevent 164

    # keep screen on
    adb shell svc power stayon true

    # hide system ui
    adb shell service call activity 42 s16 com.android.systemui
    # if xiaomi device disable miui screen

    adb push ./black.html sdcard/black.html
    # set permission for html file
    adb shell chmod 777 sdcard/black.html
    # start a black html page to prevent screen from blank
    # send file to device

    # loop
    while true; do
        set_photo
        # open image in device (old android)
        # unlock device

        # open black html page
        open_black
        # kill gallery3d
        close_galleryapp
        adb shell input keyevent 82

        adb shell am start -a android.intent.action.VIEW -d file:///sdcard/image.jpg -t image/jpeg

        # touch image in device (new android)

        sleep .5
        adb shell input tap 500 500

        sleep $time
    done

fi
