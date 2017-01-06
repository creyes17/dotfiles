function () {
	### History

	export HISTSIZE=10000000;
	export SAVEHIST=10000000

	# Ignore duplicates in command history by actively deleting the oldest duplicate as commands are typed.
	setopt HIST_IGNORE_ALL_DUPS;
	# Expire duplicate entries first when trimming history.
	setopt HIST_EXPIRE_DUPS_FIRST;
	# Write to the history file immediately, not when the shell exits.
	setopt INC_APPEND_HISTORY;
	# Share history between all sessions.
	setopt SHARE_HISTORY;
	# Don't record an entry starting with a space.
	setopt HIST_IGNORE_SPACE;
	# Remove superfluous blanks before recording entry.
	setopt HIST_REDUCE_BLANKS;
	# Don't execute immediately upon history expansion.
	setopt HIST_VERIFY;
	# Beep when accessing nonexistent history.
	setopt HIST_BEEP;

	### Paths and Other Important Variables

	export PERLPATH="/usr/local/Cellar/perl/5.24.0_1";
	export ANDROID_HOME="$HOME/Library/Android/sdk"; #TODO: This is for Mac, but need this to also work for Ubuntu
	export GOPATH="$HOME/golang";
	export VIMHOME="$HOME/.vim";

	export PATH="/Applications/LilyPond.app/Contents/Resources/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$GOPATH/bin:$VIMHOME/bin:$PERLPATH/bin:$PATH";

	### Useful Functions
	
	# Recursive Grep
	# Recursively looks through the current (or specified) directory for the given search term
	function rgrep {
		if [[ $# -eq 0 ]]; then
			echo "Usage: rgrep [options] [search query]";
			echo "Valid options:";
			echo "    -d    Directory. Specify a directory other than the current directory in which to look";
		fi

		local backupoptind=$OPTIND;

		local dir=".";

		while getopts ":d:" opt; do
			case $opt in
				d)
					local dir=$OPTARG;
					;;
			esac
		done

		# Move past the last option we examined
		shift $(expr $OPTIND - 1);

		grep -r "$@" $dir;

		export OPTIND=$backupoptind;
	}

	### Aliases

	local zshcustom="$HOME/.oh-my-zsh/custom";

	alias .bp=". $zshcustom/creyes.zsh";
	alias .brc=". $zshcustom/creyes.zsh";
	alias cdcs="cd $HOME/xamarin";
	alias cdgo="cd $GOPATH/src/github.com/creyes17";
	alias cdjs="cd $HOME/node";
	alias cdperl="cd $HOME/perl";
	alias f="fg";
	alias gobuildandtest="go build; go install; go test";
	alias j="jobs";
	alias vimbp="vim $zshcustom/creyes.zsh";
	alias vimbrc="vim $zshcustom/creyes.zsh";
	alias vimvrc="vim $HOME/.vimrc";
	alias whatismyip="dig +short myip.opendns.com @resolver1.opendns.com";
}
