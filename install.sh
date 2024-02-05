#!/bin/sh
# Flavien PERIER <perier@flavien.io>

set -e

BASE_URL="https://raw.githubusercontent.com/flavien-perier/linux-shell-configuration/master"
CONF_URL="$BASE_URL/conf"

TMP_BIN_DIR="/tmp/lsc/bin"
TMP_CONF_DIR="/tmp/lsc/conf"
TMP_ZNAP_DIR="/tmp/lsc/znap"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

is_root() {
    test $(id -u) -eq 0
}

get_package_manager() {
    if command_exists "apt-get"
    then
        echo "Use apt-get package manager."
        apt-get update -qq
        eval "$1='apt-get install -y -qq'"
        return 0
    fi

    if command_exists "dnf"
    then
        echo "Use dnf package manager."
        eval "$1='dnf install -y -q'"
        return 0
    fi

    if command_exists "yum"
    then
        echo "Use yum package manager."
        eval  "$1='yum install -y -q'"
        return 0
    fi

    if command_exists "apk"
    then
        echo "Use apk package manager."
        eval "$1='apk add --update --no-cache'"
        return 0
    fi

    if command_exists "pacman"
    then
        echo "Use pacman package manager."
        eval "$1='pacman --noconfirm -S'"
        return 0
    fi

    echo "No known package manager detected."
    exit -1
}

install_tools() {
    get_package_manager PACKAGE_MANAGER

    if ! command_exists "bash"
    then
        $PACKAGE_MANAGER bash
        echo "Bash installed"
    fi

    if ! command_exists "zsh"
    then
        $PACKAGE_MANAGER zsh
        echo "Zsh installed"
    fi

    if ! command_exists "fish"
    then
        $PACKAGE_MANAGER fish
        echo "Fish installed"
    fi
    
    if ! command_exists "nvim"
    then
        $PACKAGE_MANAGER neovim
        echo "Neovim installed"
    fi
    
    if ! command_exists "tree"
    then
        $PACKAGE_MANAGER tree
        echo "Tree installed"
    fi
    
    if ! command_exists "htop"
    then
        $PACKAGE_MANAGER htop
        echo "Htop installed"
    fi
    
    if ! command_exists "git"
    then
        $PACKAGE_MANAGER git
        echo "Git installed"
    fi
    
    if ! command_exists "curl"
    then
        $PACKAGE_MANAGER curl
        echo "Curl installed"
    fi
    
    if ! command_exists "wget"
    then
        $PACKAGE_MANAGER wget
        echo "Wget installed"
    fi
    
    if ! command_exists "gawk"
    then
        $PACKAGE_MANAGER gawk
        echo "Gawk installed"
    fi

    echo "Installation of external tools is now complete."
}

download_bin() {
    mkdir -p $TMP_BIN_DIR
}

download_conf() {
    mkdir -p $TMP_CONF_DIR

    curl -s $BASE_URL/conf/alias > $TMP_CONF_DIR/alias
    curl -s $BASE_URL/conf/bashrc > $TMP_CONF_DIR/bashrc
    curl -s $BASE_URL/conf/fishrc > $TMP_CONF_DIR/fishrc
    curl -s $BASE_URL/conf/neovim > $TMP_CONF_DIR/neovim
    curl -s $BASE_URL/conf/profile > $TMP_CONF_DIR/profile
    curl -s $BASE_URL/conf/zshrc > $TMP_CONF_DIR/zshrc
}

download_znap() {
    mkdir -p $TMP_ZNAP_DIR

    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git $TMP_ZNAP_DIR
}

install_conf() {
    USER_NAME=$1
    USER_HOME=$2

    # Alias
    cat $TMP_CONF_DIR/alias | tee $USER_HOME/.alias
    chown $USER_NAME:$USER_NAME $USER_HOME/.alias

    # Bash
    cat $TMP_CONF_DIR/bashrc | tee $USER_HOME/.bashrc
    chown $USER_NAME:$USER_NAME $USER_HOME/.bashrc

    # Zsh
    cat $TMP_CONF_DIR/zshrc | tee $USER_HOME/.zshrc
    chown $USER_NAME:$USER_NAME $USER_HOME/.zshrc
    rm -Rf $USER_HOME/.znap
    mkdir -p $USER_HOME/.znap
    cp -r $TMP_ZNAP_DIR $USER_HOME/.znap/znap
    chown $USER_NAME:$USER_NAME $USER_HOME/.znap

    # Fish
    mkdir -p $USER_HOME/.config/fish
    cat $TMP_CONF_DIR/fishrc | tee $USER_HOME/.config/fish/config.fish

    # Neovim
    mkdir -p $USER_HOME/.config/nvim
    cat $TMP_CONF_DIR/neovim | tee $USER_HOME/.config/nvim/init.vim
    chown -R $USER_NAME:$USER_NAME $USER_HOME/.config/nvim

    mkdir -p $USER_HOME/bin
    if [ -d $TMP_BIN_DIR ]
    then
        cp -R $TMP_BIN_DIR/* $USER_HOME/bin/
    fi
    chmod -R 500 $USER_HOME/bin
    chown -R $USER_NAME:$USER_NAME $USER_HOME/bin

    if [ -f $USER_HOME/.profile ]
    then
        cat $TMP_CONF_DIR/neovim | tee $USER_HOME/.profile
    elif [ -f $USER_HOME/.bash_profile ]
    then
        cat $TMP_CONF_DIR/neovim | tee $USER_HOME/.bash_profile
    fi
}

clean_after_install() {
    rm -Rf $TMP_BIN_DIR
    rm -Rf $TMP_CONF_DIR
    rm -Rf $TMP_ZNAP_DIR
}

main() {
    echo "Start of installation."

    if is_root
    then
        install_tools
        download_bin
        download_conf
        download_znap
        
        install_conf root ~
        command_exists chsh && chsh -s /bin/bash

        rm -Rf /etc/skel
        mkdir -p /etc/skel
        install_conf root /etc/skel

        for USER_INFOS in $(cat /etc/passwd | cut -f1,6 -d: | grep ":/home/")
        do
            install_conf "$(echo $USER_INFOS | cut -f1 -d:)" "$(echo $USER_INFOS | cut -f2 -d:)"
            command_exists chsh && chsh -s $(which fish) "$(echo $USER_INFOS | cut -f1 -d:)"
        done
    else
        install_conf $USER ~
    fi
    clean_after_install
    echo "End of installation."
}

main