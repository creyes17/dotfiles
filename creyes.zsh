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

	export GOPATH="$HOME/golang";
	export ANDROID_HOME="$HOME/Library/Android/sdk"; #TODO: This is for Mac, but need this to also work for Ubuntu
	export PATH="/Applications/LilyPond.app/Contents/Resources/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$GOPATH/bin:$PATH";

	### Aliases

	local zshcustom="$HOME/.oh-my-zsh/custom";

	alias .bp=". $zshcustom/creyes.zsh";
	alias .brc=". $zshcustom/creyes.zsh";
	alias f="fg";
	alias j="jobs";
	alias vimbp="vim $zshcustom/creyes.zsh";
	alias vimbrc="vim $zshcustom/creyes.zsh";
	alias vimvrc="vim $HOME/.vimrc";
}
