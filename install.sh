#!/bin/bash

# Enable unofficial "Strict mode"
set -euo pipefail;
IFS=$'\n\t';

# Exit Codes
readonly e_invalid_input=1;
readonly e_no_tmp_file=2;
readonly e_setup_failed=3;

usage() {
	cat <<-USAGE
		Sets up a fresh Mac environment with files in this dotfiles directory

		usage: $0
		    -h                              Display this help text and return

		Relevant Environment Variables
		    NONE

		Dependencies
		    curl

		Side Effects
		    Installs multiple tools and preferences

		Exit Codes
		    $e_invalid_input                               Invalid argument
		    $e_no_tmp_file                               Unable to create temporary file or directory
		    $e_setup_failed                               Some setup step did not finish correctly
USAGE
}

readonly tmp_dir=$(mktemp -d -t "$(basename $0)-$$-install.XXXXXXXX") || exit $e_no_tmp_file;
readonly script_dir_rel=$(dirname $0);
readonly script_dir_abs=$(cd $script_dir_rel >/dev/null && pwd);

#=== FUNCTION ================================================================
# NAME: cleanup
# DESCRIPTION: Deletes temporary files. Should be called when script exits
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: None.
# EXIT CODES: None.
#=============================================================================
cleanup() {
	if [ "$tmp_dir" != "/" ]; then
		rm -rf $tmp_dir;
	fi
	return 0;
}
trap cleanup EXIT;

#=== FUNCTION ================================================================
# NAME: setup_zsh
# DESCRIPTION: Sets up oh-my-zsh
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: Installs oh-my-zsh to the $HOME/.oh-my-zsh directory
# DEPENDENCIES: curl
# EXIT CODES: None.
#=============================================================================
setup_zsh() {
	# curl downloads the install script from oh-my-zsh
	# Curl's -f option fails silently on server errors
	# The -s option hides progress bars and other curl-specific output
	# The -S option shows an error message if it does fail
	# The -L option will cause curl to follow redirect links if the requested content has moved
	local zsh_install="$tmp_dir/zsh_install.sh";
	curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o "$zsh_install";

	# Run the actual install script
	source $zsh_install;

	# Install my specific settings to the custom directory
	ln -s "$(dirname $0)/creyes.zsh" "$HOME/.oh-my-zsh/custom";

	return 0;
}

#=== FUNCTION ================================================================
# NAME: has_zsh_setup
# DESCRIPTION: Checks that zsh was set up correctly and completely
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: Echoes the return exit code to STDOUT
# DEPENDENCIES: finger
# EXIT CODES: $e_setup_failed if zsh was not installed correctly.
#=============================================================================
has_zsh_setup() {
	local has_issue;

	# TODO: Check that the user's default shell was changed to zsh
	if [ "$SHELL" != "$(which zsh)" ]; then
		echo $e_setup_failed;
		return $e_setup_failed;
	fi

	# Check that the custom directory was set up
	set +e;
	ls $HOME/.oh-my-zsh/custom;
	has_issue=$?;
	set -e;

	if [ "$custom_dir" -ne 0 ]; then
		echo $e_setup_failed;
		return $e_setup_failed;
	fi

	# TODO: Check that the appropriate files were linked from that custom directory

	return 0;
}

#=== FUNCTION ================================================================
# NAME: setup_vim
# DESCRIPTION: Sets up vim
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: Installs vim settings to ~/.vim and ~/.vimrc, as well as installing used plugins
# DEPENDENCIES: git, python
# EXIT CODES: None.
#=============================================================================
setup_vim() {
	local ycm="valloric/YouCompleteMe";
	local plugins=("$ycm" "gberenfield/cljfold.vim" "Shutnik/jshint2.vim" "chumakd/perlomni.vim" "kien/rainbow_parentheses.vim" "scrooloose/syntastic" "guns/vim-clojure-static" "tpope/vim-fireplace" "pangloss/vim-javascript"); 

	# TODO: Use git submodules instead
	for plugin in "${plugins[@]}"; do
		local destination="$script_dir_abs/../../$plugin";
		if [ ! -d "$destination" ]; then
			git clone "https://github.com/${plugin}.git" "$destination";

			if [ "$plugin" == "$ycm" ]; then
				# Setup YouCompleteMe
				git -C "$script_dir_abs/../../$ycm" submodule update --init --recursive;
				python "$script_dir_abs/../../$ycm/install.py" --go-completer --js-completer --java-completer;
			fi
		fi
	done

	if [ ! -d "$HOME/.vim" ]; then
		ln -s "$script_dir_abs/.vim" "$HOME";
	fi

	if [ ! -e "$HOME/.vimrc" ]; then
		ln -s "$script_dir_abs/.vimrc" "$HOME";
	fi

	return 0;
}

#=== FUNCTION ================================================================
# NAME: has_vim_setup
# DESCRIPTION: Tests that vim was setup properly
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: Echoes the return exit code to STDOUT
# DEPENDENCIES: None.
# EXIT CODES: $e_setup_failed if vim was not setup correctly.
#=============================================================================
has_vim_setup() {
	# TODO: Add tests
	return 0;
}

#=== FUNCTION ================================================================
# NAME: setup_caffeine
# DESCRIPTION: Sets up caffeine to prevent Mac from going to sleep
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: Installs caffeine to ~/Applications
# DEPENDENCIES: curl, unzip
# EXIT CODES: None.
#=============================================================================
setup_caffeine() {
	local applications="$HOME/Applications";
	local caffeine="$applications/Caffeine.app";
	if [ ! -d "$caffeine" ]; then
		curl -fsSL http://download.lightheadsw.com/download.php\?software\=caffeine -o "$tmp_dir/caffeine.zip";
		unzip "$tmp_dir/caffeine.zip" -d "$HOME/Applications";
		open -a "$caffeine";
	fi
	return 0;
}

#=== FUNCTION ================================================================
# NAME: has_caffeine_setup
# DESCRIPTION: Checks that caffeine was installed
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: Echoes the return exit code to STDOUT
# DEPENDENCIES: None.
# EXIT CODES: $e_setup_failed if caffeine was not installed correctly.
#=============================================================================
has_caffeine_setup() {
	if [ ! -d "$caffeine" ]; then
		echo $e_setup_failed;
		return $e_setup_failed;
	fi
	return 0;
}

main() {
	while getopts "h" opt; do
		case $opt in
			h)
				usage;
				return 0;
				;;
			*)
				echo "Invalid argument!" >&2
				usage;
				return $e_invalid_input;
		esac;
	done;

	#setup_zsh; #TODO: Make zsh setup idempotent
	setup_vim;
	setup_caffeine;

	return 0;
}

main "$@";
