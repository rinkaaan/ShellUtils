# ln -sf $HOME/workplace/Utils/ShellUtils/startup.sh $HOME/startup.sh

source ~/workplace/Utils/ShellUtils/git.sh
source ~/workplace/Utils/ShellUtils/files.sh
source ~/workplace/Utils/ShellUtils/python.sh
source ~/workplace/Utils/ShellUtils/npm.sh
source ~/workplace/Utils/ShellUtils/docker.sh
export PATH=$PATH:~/workplace/Utils/ShellUtils

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
