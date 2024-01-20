#pyenv virtualenv 3.12 WebAppTemplate
#pyenv local WebAppTemplate

new-pyenv() {
  current_dir=$(basename "$PWD")
  echo "Creating pyenv virtualenv $current_dir"
  pyenv virtualenv "${1:-3.12}" "$current_dir"
  pyenv local "$current_dir"
  touch requirements.txt
}

delete-pyenv() {
  current_dir=$(basename "$PWD")
  echo "Deleting pyenv virtualenv $current_dir"
  pyenv uninstall "$current_dir"
}

py-install() {
  pip install -r requirements.txt
}
