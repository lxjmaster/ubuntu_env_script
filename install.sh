#!/usr/bin/env bash

# init
#sudo apt update && sudo apt upgrade -y

PYTHON="$(command -v python)"
PYTHON3="$(command -v python3)"
ZSH=~/.oh-my-zsh
PWD=$(pwd)
ZSH_PLUGINS="$ZSH/plugins"
CURRENT_DIR=$(cd "$(dirname "$0")" || exit 1; pwd)
ZSH_CONFIG_FILE=$CURRENT_DIR/.zshrc

if [ ! "$PYTHON" ]; then
  echo "Command 'python' not found"
  if [ ! "$PYTHON3" ]; then
    echo "Command 'python3' not found, installing python3"
    sudo apt install python3 -y
    PYTHON3="$(command -v python3)"
    sudo link "$PYTHON3" /usr/bin/python
  else
    echo "Command 'python3' existed, make link python3 to python"
    sudo link "$PYTHON3" /usr/bin/python
  fi
fi

install()
{
  if ! which "$1" > /dev/null 2>&1; then
    echo "installing $1 ..."

    if which apt > /dev/null 2>&1; then
      sudo apt install "$1" -y
    fi
    if which yum > /dev/null 2>&1; then
      sudo yum install "$1" -y
    fi
  fi
}

install_zsh_plugin()
{
  if ( ! which "$1" > /dev/null 2>&1 ) && ( ! which "$2" > /dev/null 2>&1 ); then
      PLUGIN_PATH=$ZSH_PLUGINS/$1
      if [ -d "$PLUGIN_PATH" ]; then
        echo "$1 existed, pull lasted version ..."
        cd "$PLUGIN_PATH" || exit 1
        git pull
        cd "$PWD" || exit 1
      else
        echo "installing $1 ..."
        git clone "$2" "$PLUGIN_PATH" || {
          echo "Error: git clone $1 failed"
          exit 1
        }
      fi
  fi
}

# install curl
if [ ! "$(command -v curl)" ]; then
  install curl
else
  echo "curl is installed ..." >&2
fi

# install wget
if [ ! "$(command -v wget)" ]; then
  install wget
else
  echo "wget is installed ..." >&2
fi

# install git
if [ ! "$(command -v git)" ]; then
  install git
else
  echo "git is installed ..." >&2
fi

# install zsh
if [ ! "$(command -v zsh)" ]; then
  install zsh
else
  echo "zsh is installed ..."
fi

# install oh-my-zsh
echo "installing oh-my-zsh ..."
if [ ! -d $ZSH ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --skip-chsh"
else
  rm -rf $ZSH
  sh -c "$(curl -fsS https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --skip-chsh"
fi

# install git flow
if [ ! "$(command -v git-flow)" ]; then
  install git-flow
else
  echo "git-flow is installed ..." >&2
fi

# install fzf
if [ ! "$(command -v fzf)" ]; then
  install fzf
else
  echo "fzf is installed ..." >&2
fi

# install tmux
if [ ! "$(command -v tmux)" ]; then
  install tmux
else
  echo "tmux is installed ..." >&2
fi

# config .zshrc
echo "making zsh config > .zshrc"
echo "$ZSH_CONFIG_FILE"
if [ -f "$ZSH_CONFIG_FILE" ]; then
  echo "moving $ZSH_CONFIG_FILE to $HOME/.zshrc"
  mv "$ZSH_CONFIG_FILE" "$HOME/.zshrc"
else
  echo "coping zshrc-template > .zshrc"
  cp "$ZSH/templates/zshrc.zsh-template" "$HOME/.zshrc"
fi

# install zsh-syntax-highlighting
install_zsh_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git

# install zsh-autosuggestions
install_zsh_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git

# install git-open
install_zsh_plugin git-open https://github.com/paulirish/git-open.git

# install fzf-tab
install_zsh_plugin fzf-tab https://github.com/Aloxaf/fzf-tab

# install autojump
#if [ ! "$(command -v autojump)" ]; then
#  echo "autojump not found, installing autojump"
#  if [ ! -d "$HOME/autojump" ]; then
#    cd "$HOME" || exit 1
#    git clone https://github.com/wting/autojump.git || {
#      printf "Error: git clone autojump failed"
#    }
#    cd autojump || exit 1
#    sudo ./install.py
#  else
#    cd "$HOME/autojump" || exit 1
#    git pull
#    sudo ./install.py
#  fi
#fi

# set default shell to zsh
if [ "$(command -v zsh)" ]; then
  chsh -s /bin/zsh
  cd "$HOME" || exit 1
  source .zshrc
fi

# set default terminal to tmux
#if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#  exec tmux
#fi