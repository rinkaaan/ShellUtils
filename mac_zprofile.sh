# ln -sf $HOME/workplace/Utils/ShellUtils/mac_zprofile.sh $HOME/.zprofile

export PATH="/opt/homebrew/bin:$PATH"
export PATH="/Users/lincolnnguyen/Library/Application Support/JetBrains/Toolbox/scripts:$PATH"

# Other
setopt +o nomatch
alias terminal='open -a Terminal'
eval "$(/opt/homebrew/bin/brew shellenv)"

# Python
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
echo 'eval "$(pyenv init -)"' >> ~/.profile

source ~/startup.sh
