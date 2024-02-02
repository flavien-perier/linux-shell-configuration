#!/bin/sh
# Flavien PERIER <perier@flavien.io>

set -e

BASE_URL="https://raw.githubusercontent.com/flavien-perier/linux-shell-configuration/master"
CONF_URL="$BASE_URL/conf"

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
    if is_root
    then
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
    else
        echo "The script is not executed in root mode. Installation of third-party tools aborted."
    fi
}

main() {
    echo "Start of installation."
    install_tools
    echo "End of installation."
}

main