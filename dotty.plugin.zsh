#!/bin/zsh

function dotty-track {
	dotty-git add -f $@
	dotty-git commit -m "Tracked $@"
}

function dotty-untrack {
	dotty-git rm --cached $@
	dotty-git commit -m "Untracked $@"
}

function dotty-rm {
	dotty-untrack $@
}

function dotty-add {
	dotty-track $@
}

function dotty-status {
	dotty-git status
}

function dotty-remote {
	if [[ -z "$(dotty-git remote show -n origin | grep /$1.git)" ]]; then
		dotty-git remote add -t master origin git://github.com/$1.git
		dotty-git remote set-url --push origin git@github.com:$1.git
		dotty-sync
		dotty-git reset origin/master --hard
	fi
}

function dotty-sync {
	dotty-git commit -am 'Updating tracked files'
	dotty-git pull --rebase origin
	dotty-git push origin
}

function dotty-diff {
	dotty-git diff
}

function dotty-git {
	git --git-dir=$HOME/.dotty --work-tree=$HOME $@
}

function dotty-ls {
	dotty-git ls-files
}

function dotty-init {
	dotty-git init
	print '/*\n!.*\n*~\n.config\n.netrc\n.*_userrc\n.*_history\n.ssh/id_rsa*\n!.ssh/id_rsa*.pub' >> ~/.dotty/info/exclude
}

function dotty {
	local cmd=$1; [[ $# -ge 1 ]] && shift
	[[ ! -d ~/.dotty ]] && dotty-init

	[[ -z "$cmd" ]] && print 'Please specify a command' && return 1

	if functions dotty-$cmd > /dev/null; then
		dotty-$cmd $@
	else
		print "Unnown command: $cmd"
	fi
}

# completion
function _dotty {
	emulate -L zsh

	local curcontext="$curcontext" context state state_descr line
	local -A opt_args

	_arguments \
		'1: :->command' \
		'*: :->argument' \
		--

	[[ $state = command ]] &&
		compadd -- ${="$(whence -mw 'dotty-*')"//(dotty-|: (function|alias|command))}
}

compdef _dotty dotty
