#pyenv virtualenv 3.12 WebAppTemplate
#pyenv local WebAppTemplate

# create function that creates pyenv virtualenv using name of current directory
new-pyenv() {
  current_dir=$(basename "$PWD")
  echo "Creating pyenv virtualenv $current_dir"
  pyenv virtualenv 3.12 "$current_dir"
  pyenv local "$current_dir"
}

use-pyenv() {
  current_dir=$(basename "$PWD")
  echo "Using pyenv virtualenv $current_dir"
  pyenv activate "$current_dir-3.12"
}
