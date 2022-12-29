# init
#sudo apt update && sudo apt upgrade -y

ZSH=~/.oh-my-zsh
PWD=$(pwd)
ZSH_PLUGINS="$ZSH/plugins"

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
  git clone https://github.com/robbyrussell/oh-my-zsh.git $ZSH_CUSTOM || {
    printf "Error: git clone oh-my-zsh failed"
    exit 1
  }
else
  cd $ZSH || exit 1
  git pull
  cd "$PWD" || exit 1
fi

# install zsh-syntax-highlighting
