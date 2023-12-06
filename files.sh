chmod-all() {
  find . -type f -exec chmod +x {} \;
}

chmod-run() {
  chmod +x "$1"
  "$1"
}
