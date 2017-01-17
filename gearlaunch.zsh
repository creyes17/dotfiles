# Make some further updates to my PATH for work

export GLHOME="$HOME/github/GearLaunch/hub";
export GLPORT=7432;
export GLPORTSECURE=7433;

export GLUSERNAME="chris_reyes";
export GLHOST="mole.gearint.com";

export PATH="$PATH:$HOME/bin/google-cloud-sdk/bin:$GLHOME/node_modules/.bin:$HOME/Library/Google/appengine-java-sdk/bin";

# Useful functions

# Gets the current git branch and writes it to STDOUT.
# Writes an error to STDERR if not currently in a git repo. (Writes nothing to STDOUT in that case)
function get_git_branch {
	git rev-parse --abbrev-ref HEAD;
}

# Get Pivotal Ticket ID
# Given the branch, finds the pivotal ticket ID
function get_pivotal_id {
	local branch=$(get_git_branch);

	if [[ -z $branch ]]; then
		echo "Could not obtain a git branch" >&2;
		return;
	fi

	# Find a segment in the git branch that is composed entirely of numbers
	local id=$(echo $branch | sed -nEe 's/.*-([[:digit:]]+)(-.*)?$/\1/p');

	if [[ -z $id ]]; then
		echo "Git branch doesn't contain a pivotal id" >&2;
		return;
	fi

	echo $id;
	return;
}

# Git commit
# Automatically prepends the pivotal task id to the beginning of the commit message
# Usage: 
function gitco {
	if [[ -z $1 ]]; then
		echo "Usage: gitco [commit message]" >&2;
		return
	fi

	local id=$(get_pivotal_id);

	if [[ -z $id ]]; then
		echo "Could not find pivotal ID. Skipping commit" >&2;
		return
	fi

	git commit -m "[#${id}] $@";
}

# Useful aliases
alias .bgl="source $HOME/.oh-my-zsh/custom/gearlaunch.zsh";
alias gltun="autossh -M $GLPORTSECURE -R ${GLPORT}:localhost:8080 -nNT ${GLUSERNAME}@${GLHOST}";
alias mole="ssh ${GLUSERNAME}@${GLHOST}";
alias pg-start="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start";
alias pg-stop="pg_ctl -D /usr/local/var/postgres stop";
alias vimgl="vim $HOME/.oh-my-zsh/custom/gearlaunch.zsh";
