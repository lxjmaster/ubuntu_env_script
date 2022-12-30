# init
#sudo apt update && sudo apt upgrade -y

ZSH=~/.oh-my-zsh
PWD=$(pwd)
ZSH_PLUGINS="$ZSH/plugins"
CURRENT_DIR=$(cd "$(dirname "$0")" || exit 1; pwd)
ZSH_CONFIG_FILE=$CURRENT_DIR/.zshrc

install()
{
  if ! which "$1" > /dev/null 2>&1; then
    echo "install $1 ..."

    if which apt > /dev/null 2>&1; then
      sudo apt install "$1" -y
    fi
    if which yum > /dev/null 2>&1; then
      sudo yum install "$1" -y
    fi
  fi
}

# Check if the dependent tools are installed

# install curl
if [ ! "$(command -v curl)" ]; then
  install curl
else
  echo "curl is installed..." >&2
fi

# install wget
if [ ! "$(command -v wget)" ]; then
  install wget
else
  echo "wget is installed..." >&2
fi

# install git
if [ ! "$(command -v git)" ]; then
  install git
else
  echo "git is installed..." >&2
fi

# install git flow
if [ ! "$(command -v git-flow)" ]; then
  install git-flow
else
  echo "git-flow is installed..." >&2
fi

# install zsh
if [ ! "$(command -v zsh)" ]; then
  install zsh
else
  echo "zsh is installed..."
fi

# install oh-my-zsh
if [ ! -d $ZSH ]; then
  echo "install oh-my-zsh..."
  git clone https://github.com/robbyrussell/oh-my-zsh.git "$ZSH" || {
    printf "Error: git clone oh-my-zsh failed"
    exit 1
  }
else
  cd $ZSH || exit 1
  git pull
  cd "$PWD" || exit 1
fi

# config .zshrc
echo "make zsh config, .zshrc"
if [ -d "$ZSH_CONFIG_FILE" ]; then
  echo "moving $ZSH_CONFIG_FILE to $HOME/.zshrc"
  mv "$ZSH_CONFIG_FILE" "$HOME/.zshrc"
else
  cp "$ZSH/templates/zshrc.zsh-template" "$HOME/.zshrc"
fi

# install zsh-syntax-highlighting
PLUGIN_PATH=$ZSH_PLUGINS/zsh-syntax-highlighting
if [ -d $PLUGIN_PATH ]; then
  cd $PLUGIN_PATH || exit 1
  git pull
  cd "$PWD" || exit 1
else
  echo "install zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $PLUGIN_PATH || {
    printf "Error: git clone zsh-syntax-highlighting failed"
    exit 1
  }
fi

# install zsh-autosuggestions
PLUGIN_PATH=$ZSH_PLUGINS/autosuggestions
if [ -d $PLUGIN_PATH ]; then
  cd $PLUGIN_PATH || exit 1
  git pull
  cd "$PWD" || exit 1
else
  echo "install zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions.git $PLUGIN_PATH || {
    printf "Error: git clone zsh-autosuggestions failed"
    exit 1
  }
fi

