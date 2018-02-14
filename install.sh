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
		    -z                              Install oh-my-zsh. This is not idempotent as of this version, so be careful!
		    -V                              Setup Vim. This also sets up autocomplete with YouCompleteMe.
		                                        While this is idempotent, it takes a long time to execute.

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

	echo 0;
	return 0;
}

#=== FUNCTION ================================================================
# NAME: setup_vim
# DESCRIPTION: Sets up vim
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: Installs vim settings to ~/.vim and ~/.vimrc, as well as installing used plugins
# DEPENDENCIES: git, python, xcode-select, xbuild, go, tsserver, node, npm, rustc, cargo
# EXIT CODES: None.
#=============================================================================
setup_vim() {
	# Get all dependencies. This git command is idempotent
	git -C "$script_dir_abs" submodule update --init --recursive;

	# Setup YouCompleteMe
	
	# Requires xcode tools. This returns an error if already installed, so just ignore that error
	set +e;
	xcode-select --install;
	set -e;

	# TODO: Make this idempotent
	python "$script_dir_abs/third_party/valloric/YouCompleteMe/install.py" --all;

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
	echo 0;
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
	echo 0;
	return 0;
}

#=== FUNCTION ================================================================
# NAME: setup_git
# DESCRIPTION: Sets up git with global gitignore
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: Modifies git configuration
# DEPENDENCIES: git
# EXIT CODES: None.
#=============================================================================
setup_git() {
	# Check if global config file is already set:
	local no_config=0;
	local excludesfile;
	set +e;
	excludesfile=$(git config --global core.excludesfile);
	no_config=$?;
	set -e;

	if [ "$no_config" -ne 0 ]; then
		# This means the config file didn't exist
		git config --global core.excludesfile "$script_dir_abs/.gitignore_global";
	fi

	return 0;
}

#=== FUNCTION ================================================================
# NAME: has_git_setup
# DESCRIPTION: Checks that git was configured properly
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: Echoes the return exit code to STDOUT
# DEPENDENCIES: None.
# EXIT CODES: $e_setup_failed if git was not configured correctly.
#=============================================================================
has_git_setup() {
	local expected_excludesfile="$script_dir_abs/.gitignore_global";
	local no_config=0;
	local excludesfile;

	set +e;
	excludesfile=$(git config --global core.excludesfile);
	no_config=$?;
	set -e;

	if [ "$no_config" -ne 0 ]; then
		echo "Global ignore file for git not configured" >&2;
		echo $e_setup_failed;
		return $e_setup_failed;
	fi

	if [ "$excludesfile" != "$expected_excludesfile" ]; then
		echo "Global ignore file for git does not match" >&2;
		echo -e "\tActually [$excludesfile]" >&2;
		echo -e "\tExpected [$expected_excludesfile]" >&2;
		echo $e_setup_failed;
		return $e_setup_failed;
	fi

	echo 0;
	return 0;
}

#=== FUNCTION ================================================================
# NAME: setup_clojure
# DESCRIPTION: Sets up clojure with leiningen defaults
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: Installs clojure settings and various plugins
# DEPENDENCIES: None.
# EXIT CODES: None.
#=============================================================================
setup_clojure() {
	local lein_home="$HOME/.lein";
	if [ ! -d "$lein_home" ]; then
		mkdir "$lein_home";
	fi

	if [ ! -e "$lein_home/profiles.clj" ]; then
		ln -s "$script_dir_abs/profiles.clj" "$lein_home";
	fi

	return 0;
}

main() {
	local install_zsh=false;
	local install_vim=false;

	while getopts "hz" opt; do
		case $opt in
			h)
				usage;
				return 0;
				;;
			z)
				install_zsh=true;
				;;
			V)
				install_vim=true;
				;;
			*)
				echo "Invalid argument!" >&2
				usage;
				return $e_invalid_input;
		esac;
	done;

	#TODO: Make zsh setup idempotent
	$install_zsh && setup_zsh;

	#TODO: Make vim setup idempotent
	$install_vim && setup_vim;

	setup_caffeine;
	setup_git;
	setup_clojure;

	return 0;
}

main "$@";
