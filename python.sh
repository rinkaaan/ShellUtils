#pyenv virtualenv 3.12 WebAppTemplate
#pyenv local WebAppTemplate

new-pyenv() {
  current_dir=$(basename "$PWD")
  echo "Creating pyenv virtualenv $current_dir using version ${1:-3.12}"
  pyenv virtualenv "${1:-3.12}" "$current_dir"
  pyenv local "$current_dir"
  touch requirements.txt
  python3.12 -m pip install --upgrade pip
}

delete-pyenv() {
  current_dir=$(basename "$PWD")
  echo "Deleting pyenv virtualenv $current_dir"
  pyenv uninstall "$current_dir"
}

py-install() {
  pip install -r requirements.txt
}
