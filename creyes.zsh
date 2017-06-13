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
	export NVM_DIR="$HOME/.nvm";

	export PATH="$HOME/bin:/Applications/LilyPond.app/Contents/Resources/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$GOPATH/bin:$VIMHOME/bin:$PERLPATH/bin:$PATH";
	export PATH="$NVM_DIR/versions/node/v7.10.0/bin/npm:$PATH";

	export EDITOR="vim -u NONE";

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

		local extra_opts="";

		while getopts "id:" opt; do
			case $opt in
				d)
					local dir=$OPTARG;
					;;
				i)
					local extra_opts="$extra_opts -i";
					;;
			esac
		done

		# Move past the last option we examined
		shift $(expr $OPTIND - 1);

		eval grep -r "$extra_opts" "$*" $dir;

		export OPTIND=$backupoptind;
	}

	# View a small window of a file
	# Probably needs a better name
	function window {
		local usage=$( cat <<USAGE
Usage: window [options] filename
Valid options:
	You must specify exactly two of the following options
	-s	The line at which to start displaying from the file
	-e	The line at which to stop displaying from the file
	-n	The number of lines to display
USAGE
);

		if [[ $# -eq 0 ]]; then
			echo $usage;
			return 1
		fi

		local backupoptind=$OPTIND;

		local start='';

		local stop='';

		local lines='';

		local argCount=0;

		while getopts "s:e:n:h" opt; do
			case $opt in
				s)
					if [ ! -z $start ]; then
						echo "Cannot specify the same option multiple times: -s";
						echo $usage;
						return 3
					fi
					local start=$OPTARG;
					local argCount=$(expr $argCount + 1);
					;;
				e)
					if [ ! -z $stop ]; then
						echo "Cannot specify the same option multiple times: -e";
						echo $usage;
						return 4
					fi
					local stop=$OPTARG;
					local argCount=$(expr $argCount + 1);
					;;
				n)
					if [ ! -z $lines ]; then
						echo "Cannot specify the same option multiple times: -n";
						echo $usage;
						return 5
					fi
					local lines=$OPTARG;
					local argCount=$(expr $argCount + 1);
					;;
				h)
					echo $usage;
					return 0;
					;;
			esac
		done

		if [ "$argCount" -ne 2 ]; then
			echo "Exactly two unique options of -s, -e, and -n are required";
			echo $usage;
			return 2;
		fi

		# Move past the last option we examined
		shift $(expr $OPTIND - 1);

		local file=$1;

		# Tail is number of lines
		# Head is stop line

		# Test cases
		#+-----------+-------+------+-------++------+------+
		#| File Size | Start | Stop | Count || HEAD | TAIL |
		#+-----------+-------+------+-------++------+------+
		#|    10     |   1   |  10  |       ||  10  |  10  |
		#+-----------+-------+------+-------++------+------+
		#|    20     |   1   |  10  |       ||  10  |  10  |
		#+-----------+-------+------+-------++------+------+
		#|    20     |   11  |  20  |       ||  20  |  10  |
		#+-----------+-------+------+-------++------+------+
		#|    20     |   1   |      |  10   ||  10  |  10  |
		#+-----------+-------+------+-------++------+------+
		#|    20     |   11  |      |  10   ||  20  |  10  |
		#+-----------+-------+------+-------++------+------+
		#|    20     |       |  10  |  10   ||  10  |  10  |
		#+-----------+-------+------+-------++------+------+
		#|    20     |       |  20  |  10   ||  20  |  10  |
		#+-----------+-------+------+-------++------+------+
		
		local tailarg=$lines;

		if [ -z $lines ]; then
			local tailarg=$(expr $stop - $start + 1)
		fi

		local headarg=$stop;

		if [ -z $stop ]; then
			local headarg=$(expr $start + $lines);
		fi

		head -n $headarg $file | tail -n $tailarg;

		export OPTIND=$backupoptind;

		return 0
	}

	# Gets the current git branch and writes it to STDOUT.
	# Writes an error to STDERR if not currently in a git repo. (Writes nothing to STDOUT in that case)
	function get_git_branch {
		git rev-parse --abbrev-ref HEAD;
	}

	### Aliases

	local zshcustom="$HOME/.oh-my-zsh/custom";

	alias .bp=". $zshcustom/creyes.zsh";
	alias .brc=". $zshcustom/creyes.zsh";
	alias .nvm=". $NVM_DIR/nvm.sh"
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
	alias untar="tar -zxvf ";
	alias gitup="git push --set-upstream origin \$(get_git_branch)";
	alias gd="git diff -w";
}
