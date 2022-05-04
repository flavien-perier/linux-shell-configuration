#!/bin/sh
# Flavien PERIER <perier@flavien.io>
# Install user profiles

print_bashrc() {
	echo '#!/bin/bash

shopt -s checkwinsize
command_not_found_handle()(printf "%s: command not found\n" "$1" >&2)

export HISTSIZE=5000
export HISTFILESIZE=5000
export HISTIGNORE="ls:ll:pwd:clear"
export HISTCONTROL="ignoredups"
export HISTFILE="$HOME/.bash_history"

git_prompt() {
	BRANCH=`git rev-parse --abbrev-ref HEAD 2>/dev/null`
	if [ $? -eq 0 ]
	then
		git diff --cached --exit-code > /dev/null
		if [ $? -eq 0 ]
		then
			printf " \e[m[\e[32m$BRANCH\e[m]\e[34m"
		else
			printf " \e[m[\e[31m$BRANCH\e[m]\e[34m"
		fi
	else
		echo -n ""
	fi
}

if [ $UID -eq 0 ]
then
	export PS1="\[\e[m\]\$(date +"%H:%M:%S") \e[1mB\e[m \[\e[31m\]\u@\H \[\e[34m\]\w\$(git_prompt)\n\[\e[31m\]#\[\e[m\] > "
else
	export PS1="\[\e[m\]\$(date +"%H:%M:%S") \e[1mB\e[m \[\e[32m\]\u@\H \[\e[34m\]\w\$(git_prompt)\n\[\e[32m\]%\[\e[m\] > "
fi

source $HOME/.alias'
}

print_zshrc() {
	echo '#!/usr/bin/env zsh

autoload -U compinit
compinit
zstyle ":completion:*:descriptions" format "%U%B%d%b%u"
zstyle ":completion:*:warnings" format "%BSorry, no matches for: %d%b"
zstyle ":completion:*:sudo:*" command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
zstyle ":completion:*" use-cache on
zstyle ":completion:*" cache-path ~/.zsh_cache

export HISTSIZE=5000
export HISTFILESIZE=5000
export HISTIGNORE="ls:ll:pwd:clear"
export HISTCONTROL="ignoredups"
export HISTFILE="$HOME/.bash_history"

zmodload zsh/complist
setopt extendedglob
setopt promptsubst
zstyle ":completion:*:*:kill:*:processes" list-colors "=(#b) #([0-9]#)*=36=31"

setopt correctall

git_prompt() {
	BRANCH=`git rev-parse --abbrev-ref HEAD 2>/dev/null`
	if [ $? -eq 0 ]
	then
		git diff --cached --exit-code > /dev/null
		if [ $? -eq 0 ]
		then
			print -Pn " %f[%F{green}$BRANCH%f]%F{blue}"
		else
			print -Pn " %f[%F{red}$BRANCH%f]%F{blue}"
		fi
	else
		print -Pn ""
	fi
}

if [ $UID -eq 0 ]
then
	export PROMPT="%f%* %BZ%b %F{red}%n@%m %F{blue}%~\$(git_prompt)
%F{red}%#%f > "
else
	export PROMPT="%f%* %BZ%b %F{green}%n@%m %F{blue}%~\$(git_prompt)
%F{green}%#%f > "
fi

source $HOME/.alias'
}

print_fishrc() {
	echo '#!/usr/bin/env fish

set --universal fish_greeting ""
set -g fish_prompt_pwd_dir_length 10

function git_prompt
	set BRANCH (git rev-parse --abbrev-ref HEAD 2>/dev/null)
	if [ $status -eq 0 ]
		git diff --cached --exit-code > /dev/null
		if [ $status -eq 0 ]
			set_color normal
			echo -n "["
			set_color green
			echo -n $BRANCH
			set_color normal
			echo -n "]"
			set_color blue
			echo -n " "
		else
			set_color normal
			echo -n "["
			set_color red
			echo -n $BRANCH
			set_color normal
			echo -n "]"
			set_color blue
			echo -n " "
		end
	else
		echo -n ""
	end
end

function fish_prompt
	set_color normal
	echo -n (date +"%H:%M:%S")
	
	set_color --bold
	echo -n " F "
	set_color normal

	if [ $USER = "root" ]
		set_color red
	else
		set_color green
	end

	echo -n $LOGNAME
	echo -n @
	echo -n (hostname)

	set_color blue

	echo -n " "
	echo -n (prompt_pwd)
	echo -n " "

	git_prompt

	echo ""

	if [ $USER = "root" ]
		set_color red
		echo -n "#"
	else
		set_color green
		echo -n "%"
	end

	set_color normal

	echo -n " > "
end

source $HOME/.alias'
}

print_neovim() {
	echo 'set number
set mouse=a
set tabstop=4
set expandtab
set shiftwidth=4
set autoindent
filetype plugin indent on
syntax on
'
}

print_profile() {
	echo '
# linux-shell-configuration
if [ -d $HOME/bin ]
then
	export PATH="$PATH:$HOME/bin"
fi'
}

print_alias_list() {
	echo '# Alias list

alias ls="ls --color=auto"
alias dir="dir --color=auto"
alias vdir="vdir --color=auto"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

alias df="df -h"
alias du="du -hs"
alias free="free -h"
alias ll="ls -alh --time-style=\"+%Y-%m-%d %H:%m\""
alias vi="nvim"'
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

download_scripts() {
	mkdir -p /tmp/user-bin

	KUBECTL_VSERSION=`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`
	DOCKER_COMPOSE_VERSION=`curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "tag_name" | awk '{match($0,"\"tag_name\": \"(.+)\",",a)}END{print a[1]}'`
	KMPOSE_VERSION=`curl -s https://api.github.com/repos/kubernetes/kompose/releases/latest | grep "tag_name" | awk '{match($0,"\"tag_name\": \"(.+)\",",a)}END{print a[1]}'`

	# Install kubectx
	curl -Lqs https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -o /tmp/user-bin/kubectx

	# Install kubens
	curl -Lqs https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o /tmp/user-bin/kubens

	case `uname -m` in
	x86_64)
		# Install kubectl
		curl -Lqs https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VSERSION/bin/linux/amd64/kubectl -o /tmp/user-bin/kubectl

		# Install docker-compose
		curl -Lqs https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-linux-x86_64 -o /tmp/user-bin/docker-compose

		# Install kompose
		curl -Lqs https://github.com/kubernetes/kompose/releases/download/$KMPOSE_VERSION/kompose-linux-amd64 -o /tmp/user-bin/kompose
		;;
	aarch64)
		# Install kubectl
		curl -Lqs https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VSERSION/bin/linux/arm64/kubectl -o /tmp/user-bin/kubectl

		# Install docker-compose
		curl -Lqs https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-linux-armv7 -o /tmp/user-bin/docker-compose

		# Install kompose
		curl -Lqs https://github.com/kubernetes/kompose/releases/download/$KMPOSE_VERSION/kompose-linux-arm64 -o /tmp/user-bin/kompose
		;;
	armv7l)
		# Install kubectl
		curl -Lqs https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VSERSION/bin/linux/arm/kubectl -o /tmp/user-bin/kubectl

		# Install docker-compose
		curl -Lqs https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-linux-armv7 -o /tmp/user-bin/docker-compose

		# Install kompose
		curl -Lqs https://github.com/kubernetes/kompose/releases/download/$KMPOSE_VERSION/kompose-linux-arm -o /tmp/user-bin/kompose
		;;
	esac
}

install_conf() {
	touch $1/.alias
	print_alias_list > $1/.alias
	chown $2:$2 $1/.alias

	touch $1/.bashrc
	print_bashrc > $1/.bashrc
	chown $2:$2 $1/.bashrc

	touch $1/.zshrc
	print_zshrc > $1/.zshrc
	chown $2:$2 $1/.zshrc

	mkdir -p $1/.config/fish
	touch $1/.config/fish/config.fish
	print_fishrc > $1/.config/fish/config.fish

	mkdir -p $1/.config/nvim
	touch $1/.config/nvim/init.vim
	print_neovim > $1/.config/nvim/init.vim

	chown $2:$2 $1/.config -R

	if [ -d /tmp/user-bin ]
	then
		mkdir -p $1/bin
		cp -R /tmp/user-bin/* $1/bin/
		chmod -R 500 $1/bin
		chown -R $2:$2 $1/bin
	fi

	PROFILE_FILE="no_profile"
	if [ -f $1/.profile ]
	then
		PROFILE_FILE="$1/.profile"
	elif [ -f $1/.bash_profile ]
	then
		PROFILE_FILE="$1/.bash_profile"
	fi

	if [ $PROFILE_FILE != "no_profile" ]
	then
		grep -q "# linux-shell-configuration" $PROFILE_FILE
		if [ $? -ne 0 ]
		then
			print_profile >> $PROFILE_FILE
		fi
	fi
}

echo "Installation: start"

if [ `id -u` -eq 0 ]
then
	PACKAGE_INSTALLER="echo 'Installation: FAILED' && exit -1"
	command_exists "apt-get" && apt-get update && PACKAGE_INSTALLER="apt-get install -y"
	command_exists "yum" && PACKAGE_INSTALLER="yum install -y"
	command_exists "dnf" && PACKAGE_INSTALLER="dnf install -y"
	command_exists "apk" && PACKAGE_INSTALLER="apk add --update --no-cache"
	command_exists "pacman" && PACKAGE_INSTALLER="pacman --noconfirm -S"

	command_exists "bash" || $PACKAGE_INSTALLER bash
	command_exists "zsh" || $PACKAGE_INSTALLER zsh
	command_exists "fish" || $PACKAGE_INSTALLER fish
	command_exists "nvim" || $PACKAGE_INSTALLER neovim
	command_exists "tree" || $PACKAGE_INSTALLER tree
	command_exists "htop" || $PACKAGE_INSTALLER htop
	command_exists "git" || $PACKAGE_INSTALLER git
	command_exists "curl" || $PACKAGE_INSTALLER curl
	command_exists "wget" || $PACKAGE_INSTALLER wget
	command_exists "gawk" || $PACKAGE_INSTALLER gawk

	download_scripts

	print_bashrc > /etc/bash.bashrc

	for USER_NAME in `ls /home | grep -v lost+found`
	do
		install_conf "/home/$USER_NAME" $USER_NAME
		command_exists chsh && chsh -s `which fish` $USER_NAME
	done

	install_conf ~ root
	command_exists chsh && chsh -s /bin/bash

	mkdir -p /etc/skel/
	install_conf /etc/skel root
else
	download_scripts

	install_conf ~ $USER
	command_exists chsh && chsh -s `which fish` $USER
fi

rm -Rf /tmp/user-bin

echo "Installation: OK"
