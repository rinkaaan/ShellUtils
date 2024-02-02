new-vite() {
  npm create vite@latest "$1" -- --template react-ts
  cd "$1"
  npm install
  pycharm .
}
