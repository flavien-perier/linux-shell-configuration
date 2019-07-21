#!/bin/bash
# Flavien PERIER <perier@flavien.cc>
# Install user profiles

# $1 used shell

print_bashrc() {
	echo '#!/bin/bash'
	echo ''
	echo 'shopt -s checkwinsize'
	echo 'command_not_found_handle()(printf "%s: command not found\n" "$1" >&2)'
	echo ''
	echo 'export HISTSIZE=1000'
	echo 'export HISTFILESIZE=2000'
	echo 'export HISTTIMEFORMAT="%F%T - "'
	echo 'export HISTIGNORE="ls:ll:ls -al:ls -alh:pwd:clear"'
	echo 'export HISTCONTROL="ignoredups"'
	echo ''
	echo 'git_prompt() {'
	echo '	BRANCH=`git rev-parse --abbrev-ref HEAD 2>/dev/null`'
	echo '	if [ $? -eq 0 ]'
	echo '	then'
	echo '		git diff --cached --exit-code > /dev/null'
	echo '		if [ $? -eq 0 ]'
	echo '		then'
	echo '			printf " \e[m[\e[32m$BRANCH\e[m]\e[34m"'
	echo '		else'
	echo '			printf " \e[m[\e[31m$BRANCH\e[m]\e[34m"'
	echo '		fi'
	echo '	else'
	echo '		echo -n ""'
	echo '	fi'
	echo '}'
	echo ''
	echo 'if [ $UID -eq 0 ]'
	echo 'then'
	echo '	export PS1="\[\e[m\]\$(date +"%H:%M:%S") (bash) \[\e[31m\]\u@\H \[\e[34m\]\w\$(git_prompt) # \[\e[m\]"'
	echo 'else'
	echo '	export PS1="\[\e[m\]\$(date +"%H:%M:%S") (bash) \[\e[32m\]\u@\H \[\e[34m\]\w\$(git_prompt) % \[\e[m\]"'
	echo 'fi'
	echo ''
}

print_zshrc() {
	echo '#!/usr/bin/env zsh'
	echo ''
	echo 'autoload -U compinit'
	echo 'compinit'
	echo 'zstyle ":completion:*:descriptions" format "%U%B%d%b%u"'
	echo 'zstyle ":completion:*:warnings" format "%BSorry, no matches for: %d%b"'
	echo 'zstyle ":completion:*:sudo:*" command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin'
	echo 'zstyle ":completion:*" use-cache on'
	echo 'zstyle ":completion:*" cache-path ~/.zsh_cache'
	echo ''
	echo 'zmodload zsh/complist'
	echo 'setopt extendedglob'
	echo 'setopt promptsubst'
	echo 'zstyle ":completion:*:*:kill:*:processes" list-colors "=(#b) #([0-9]#)*=36=31"'
	echo ''
	echo 'setopt correctall'
	echo ''
	echo 'git_prompt() {'
	echo '	BRANCH=`git rev-parse --abbrev-ref HEAD 2>/dev/null`'
	echo '	if [ $? -eq 0 ]'
	echo '	then'
	echo '		git diff --cached --exit-code > /dev/null'
	echo '		if [ $? -eq 0 ]'
	echo '		then'
	echo '			print -Pn " %f[%F{green}$BRANCH%f]%F{blue}"'
	echo '		else'
	echo '			print -Pn " %f[%F{red}$BRANCH%f]%F{blue}"'
	echo '		fi'
	echo '	else'
	echo '		print -Pn ""'
	echo '	fi'
	echo '}'
	echo ''
	echo 'if [ $UID -eq 0 ]'
	echo 'then'
	echo '	export PROMPT="%f%* (zsh) %F{red}%n@%m %F{blue}%~\$(git_prompt) %# %f"'
	echo 'else'
	echo '	export PROMPT="%f%* (zsh) %F{green}%n@%m %F{blue}%~\$(git_prompt) %# %f"'
	echo 'fi'
	echo ''
}

print_fishrc() {
	echo '#!/usr/bin/env fish'
	echo ''
	echo 'set --universal fish_greeting ""'
	echo 'set -g fish_prompt_pwd_dir_length 10'
	echo ''
	echo 'function git_prompt'
	echo '	set BRANCH (git rev-parse --abbrev-ref HEAD 2>/dev/null)'
	echo '	if [ $status -eq 0 ]'
	echo '		git diff --cached --exit-code > /dev/null'
	echo '		if [ $status -eq 0 ]'
	echo '			set_color normal'
	echo '			echo -n "["'
	echo '			set_color green'
	echo '			echo -n $BRANCH'
	echo '			set_color normal'
	echo '			echo -n "]"'
	echo '			set_color blue'
	echo '			echo -n " "'
	echo '		else'
	echo '			set_color normal'
	echo '			echo -n "["'
	echo '			set_color red'
	echo '			echo -n $BRANCH'
	echo '			set_color normal'
	echo '			echo -n "]"'
	echo '			set_color blue'
	echo '			echo -n " "'
	echo '		end'
	echo '	else'
	echo '		echo -n ""'
	echo '	end'
	echo 'end'
	echo ''
	echo 'function fish_prompt'
	echo '	set_color normal'
	echo '	echo -n (date +"%H:%M:%S")'
	echo '	echo -n " (fish) "'
	echo ''
	echo '	if [ $USER = "root" ]'
	echo '		set_color red'
	echo '	else'
	echo '		set_color green'
	echo '	end'
	echo ''
	echo '	echo -n $LOGNAME'
	echo '	echo -n @'
	echo '	echo -n (hostname)'
	echo ''
	echo '	set_color blue'
	echo ''
	echo '	echo -n " "'
	echo '	echo -n (prompt_pwd)'
	echo '	echo -n " "'
	echo ''
	echo '	git_prompt'
	echo ''
	echo '	if [ $USER = "root" ]'
	echo '		echo -n "# "'
	echo '	else'
	echo '		echo -n "% "'
	echo '	end'
	echo ''
	echo '	set_color normal'
	echo 'end'
	echo ''
}

print_alias_list() {
	echo 'alias ls="ls --color=auto"'
	echo 'alias dir="dir --color=auto"'
	echo 'alias vdir="vdir --color=auto"'
	echo 'alias grep="grep --color=auto"'
	echo 'alias fgrep="fgrep --color=auto"'
	echo 'alias egrep="egrep --color=auto"'
	echo ''
	echo 'alias weather="curl wttr.in"'
	echo ''
	echo 'alias bash="exec bash"'
	echo 'alias zsh="exec zsh"'
	echo 'alias fish="exec fish"'
	echo ''
	echo 'alias ll="ls -alh"'
	echo 'alias vi="vim"'
	echo ''
}

print_profile() {
	echo 'if [ $UID -eq 0 ]'
	echo 'then'
	echo '	export PS1="# > "'
	echo 'else'
	echo '	export PS1="$ > "'
	echo 'fi'
	echo ''
	echo "exec $1"
	echo ''
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
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
	command_exists "apt-get" && apt-get update && PACKAGE_INSTALLER="apt-get install"
	command_exists "yum" && PACKAGE_INSTALLER="yum install"
	command_exists "dnf" && PACKAGE_INSTALLER="dnf install"

	command_exists "bash" || $PACKAGE_INSTALLER zsh
	command_exists "zsh" || $PACKAGE_INSTALLER zsh
	command_exists "fish" || $PACKAGE_INSTALLER fish
	command_exists "vim" || $PACKAGE_INSTALLER vim
	command_exists "tree" || $PACKAGE_INSTALLER tree
	command_exists "git" || $PACKAGE_INSTALLER git
	command_exists "curl" || $PACKAGE_INSTALLER curl

	print_bashrc > /etc/bash.bashrc

	for USER_NAME in `ls /home`
	do
		install_conf "/home/$USER_NAME" $USER_NAME $SHELL
		chsh -s "/bin/bash" $USER_NAME
	done

	install_conf ~ $USER "bash"
	chsh -s /bin/bash
else
	install_conf ~ $USER $SHELL
	chsh -s /bin/bash
fi
