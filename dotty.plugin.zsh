#!/bin/zsh

function dotty-track() {
	dotty-git add -f $@
	dotty-git commit -m "Tracked $@"
}

function dotty-untrack() {
	dotty-git rm --cached $@
	dotty-git commit -m "Untracked $@"
}

function dotty-rm() {
	dotty-untrack $@
}

function dotty-add() {
	dotty-track $@
}

function dotty-status() {
	dotty-git status
}

function dotty-remote() {
	if [[ ! -d ~/.dotty ]]; then
		dotty-git clone git@github.com:$1.git
	else
		dotty-git remote add origin git@github.com:$1.git
		dotty-git branch --set-upstream master origin/master
	fi
}

function dotty-sync() {
	dotty-git fetch
	dotty-git rebase
	dotty-git commit -am 'Updating tracked files'
	dotty-git push
}

function dotty-diff() {
	dotty-git diff
}

function dotty-git() {
	git --git-dir=$HOME/.dotty --work-tree=$HOME $@
}

function dotty-ls() {
	dotty-git ls-files
}

function dotty-init() {
	dotty-git init
	print '/*\n!.*\n*~\n.config\n.netrc\n.*_userrc\n.*_history\n.ssh/id_rsa*\n!.ssh/id_rsa*.pub' >> ~/.dotty/info/exclude
}

function dotty() {
	local cmd=$1; [[ $# -ge 1 ]] && shift
	[[ ! -d ~/.dotty ]] && dotty-init

	[[ -z "$cmd" ]] && print 'Please specify a command' && return 1

	if functions dotty-$cmd > /dev/null; then
		dotty-$cmd $@
	else
		print "Unnown command: $cmd"
	fi
}
