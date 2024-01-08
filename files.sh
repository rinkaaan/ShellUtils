chmod-all() {
  find . -type f -exec chmod +x {} \;
}

chmod-run() {
  chmod +x "$1"
  "$1"
}

alias reset-usb="sudo launchctl stop com.apple.usbmuxd"
