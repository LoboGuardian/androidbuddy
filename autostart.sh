#!/bin/bash

#this script is designed to run on boot (if enabled) to popup the interface when an android device is plugged in.
#it avoids using any sort of polling loop to do this, making it use zero resources on standby.

pid=""

#solve edge case: android device present during boot
# udevadm monitor only catches new events. We check the current udev db for already connected devices.
if udevadm info --export-db | grep -q 'ID_SERIAL.*Android'; then
  echo "Android device already detected on startup"
  "$(dirname "$0")/main.sh" &
  pid=$!
fi

#each usb connection will spam multiple lines (3-5 depending on usb mode) - the first few can fail with adb not ready
#only one has to work (usually the 2nd one), and then subsequent lines are ignored to prevent duplicate scrcpy windows

udevadm monitor --environment | grep --line-buffered '^ID_SERIAL.*Android' | while read line ;do
  echo "androidbuddy autostart.sh: received $line"
  
  sleep 0.5
  if [ -z "$pid" ] || [ ! -f "/proc/$pid/status" ];then
    "$(dirname "$0")/main.sh" &
    pid=$!
  else
    echo ignoring line
  fi
  
done
