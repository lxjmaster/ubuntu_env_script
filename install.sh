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
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
else
#  rm -rf $ZSH
#  sh -c "$(curl -fsS https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
  cd $ZSH || exit 1
  git pull || {
    echo "Error: git clone oh-my-zsh failed"
  }
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
echo "making zsh config > .zshrc ..."
if [ -f "$ZSH_CONFIG_FILE" ]; then
  echo "moving $ZSH_CONFIG_FILE to $HOME/.zshrc"
  mv "$ZSH_CONFIG_FILE" "$HOME/.zshrc"
else
  echo "coping zshrc-template > .zshrc ..."
  cp "$ZSH/templates/zshrc.zsh-template" "$HOME/.zshrc" || {
    echo "copy zshrc-template failed..."
    exit 1
  }
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

setup_shell() {
  if [ "$(basename -- "$SHELL")" = "zsh" ]; then
    return
  fi

  if ! command_exists chsh; then
    cat <<EOF
Command chsh not found
EOF
    return
  fi

  # Check if we're running on Termux
  case "$PREFIX" in
    *com.termux*) termux=true; zsh=zsh ;;
    *) termux=false ;;
  esac

  if [ "$termux" != true ]; then
    # Test for the right location of the "shells" file
    if [ -f /etc/shells ]; then
      shells_file=/etc/shells
    elif [ -f /usr/share/defaults/etc/shells ]; then # Solus OS
      shells_file=/usr/share/defaults/etc/shells
    else
      echo "could not find /etc/shells file. Change your default shell manually."
      return
    fi

    # Get the path to the right zsh binary
    # 1. Use the most preceding one based on $PATH, then check that it's in the shells file
    # 2. If that fails, get a zsh path from the shells file, then check it actually exists
    if ! zsh=$(command -v zsh) || ! grep -qx "$zsh" "$shells_file"; then
      if ! zsh=$(grep '^/.*/zsh$' "$shells_file" | tail -n 1) || [ ! -f "$zsh" ]; then
        echo "no zsh binary found or not present in '$shells_file'"
        echo "change your default shell manually."
        return
      fi
    fi

    echo "Changing your shell to $zsh..."
    chsh -s "$zsh" "$USER"

    # Check if the shell change was successful
      if [ $? -ne 0 ]; then
        echo "chsh command unsuccessful. Change your default shell manually."
      else
        export SHELL="$zsh"
        echo "Shell successfully changed to '$zsh'."
      fi

      echo
  fi
}

# set default shell to zsh
setup_shell

# set default terminal to tmux
#if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#  exec tmux
#fi

sudo reboot
