# ln -sf $(pwd)/ShellUtils/startup.sh $HOME/.startup.sh

source ~/workplace/Utils/ShellUtils/git.sh
source ~/workplace/Utils/ShellUtils/files.sh
source ~/workplace/Utils/ShellUtils/python.sh
export PATH=$PATH:~/workplace/Utils/ShellUtils

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
