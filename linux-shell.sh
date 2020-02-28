#!/bin/bash
# Flavien PERIER <perier@flavien.io>
# Install user profiles

# $1 used shell

print_bashrc() {
	echo '#!/bin/bash

shopt -s checkwinsize
command_not_found_handle()(printf "%s: command not found\n" "$1" >&2)

export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTTIMEFORMAT="%F%T - "
export HISTIGNORE="ls:ll:ls -al:ls -alh:pwd:clear"
export HISTCONTROL="ignoredups"

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
	export PS1="\[\e[m\]\$(date +"%H:%M:%S") (bash) \[\e[31m\]\u@\H \[\e[34m\]\w\$(git_prompt)\n\[\e[31m\]#\[\e[m\] > "
else
	export PS1="\[\e[m\]\$(date +"%H:%M:%S") (bash) \[\e[32m\]\u@\H \[\e[34m\]\w\$(git_prompt)\n\[\e[32m\]%\[\e[m\] > "
fi'
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
	export PROMPT="%f%* (zsh) %F{red}%n@%m %F{blue}%~\$(git_prompt)
%F{red}%#%f > "
else
	export PROMPT="%f%* (zsh) %F{green}%n@%m %F{blue}%~\$(git_prompt)
%F{green}%#%f > "
fi'
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
	echo -n " (fish) "

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
end'
}

print_alias_list() {
	echo '
alias ls="ls --color=auto"
alias dir="dir --color=auto"
alias vdir="vdir --color=auto"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

alias bash="exec bash"
alias zsh="exec zsh"
alias fish="exec fish"

alias ll="ls -alh --time-style=\"+%Y-%m-%d %H:%m\""
alias vi="vim"'
}

print_profile() {
	echo 'if [ -d ~/bin ]
then
	PATH="$PATH:~/bin"
fi

if [ $UID -eq 0 ]
then
	export PS1="# > "
else
	export PS1="$ > "
fi'

	echo "exec $1"
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

download_scripts() {
	mkdir /tmp/users-bin

	curl -L https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl -o /tmp/users-bin/kubectl

	git clone https://github.com/ahmetb/kubectx.git /tmp/kubectx
	mv /tmp/kubectx/kubectx /tmp/users-bin/kubectx
	mv /tmp/kubectx/kubens /tmp/users-bin/kubens
	rm -Rf /tmp/kubectx
}

install_conf() {
	print_bashrc > $1/.bashrc
	print_alias_list >> $1/.bashrc
	chown $2:$2 $1/.bashrc

	print_zshrc > $1/.zshrc
	print_alias_list >> $1/.zshrc
	chown $2:$2 $1/.zshrc

	mkdir $1/.config/ 2>/dev/null
	mkdir $1/.config/fish 2>/dev/null
	print_fishrc > $1/.config/fish/config.fish
	print_alias_list >> $1/.config/fish/config.fish
	chown $2:$2 $1/.config -R

	if [ -d /tmp/users-bin ]
	then
		mkdir -p $1/bin
		cp -R /tmp/users-bin/* $1/bin/
		chmod -R 500 $1/bin
		chown -R $2:$2 $1/bin
	fi

	print_profile "$3" > $1/.profile
}

SHELL=$1
if [ -z "$1" ]
then
	SHELL="fish"
fi

if [ $UID -eq 0 ]
then
	PACKAGE_INSTALLER="exit -1;"
	command_exists "apt-get" && apt-get update && PACKAGE_INSTALLER="apt-get install -y"
	command_exists "yum" && PACKAGE_INSTALLER="yum install -y"
	command_exists "dnf" && PACKAGE_INSTALLER="dnf install -y"

	command_exists "bash" || $PACKAGE_INSTALLER bash
	command_exists "zsh" || $PACKAGE_INSTALLER zsh
	command_exists "fish" || $PACKAGE_INSTALLER fish
	command_exists "vim" || $PACKAGE_INSTALLER vim
	command_exists "tree" || $PACKAGE_INSTALLER tree
	command_exists "git" || $PACKAGE_INSTALLER git
	command_exists "curl" || $PACKAGE_INSTALLER curl

	download_scripts

	print_bashrc > /etc/bash.bashrc

	for USER_NAME in `ls /home`
	do
		install_conf "/home/$USER_NAME" $USER_NAME $SHELL
		chsh -s "/bin/bash" $USER_NAME
	done

	rm -Rf /tmp/users-bin

	install_conf ~ $USER "bash"
	chsh -s /bin/bash
else
	install_conf ~ $USER $SHELL
	chsh -s /bin/bash
fi
