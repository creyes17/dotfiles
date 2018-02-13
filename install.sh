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

#=== FUNCTION ================================================================
# NAME: cleanup
# DESCRIPTION: Deletes temporary files. Should be called when script exits
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# SIDE EFFECTS: None.
# EXIT CODES: None.
#=============================================================================
cleanup() {
	rm $tmp_dir;
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
	ln -s "$(dirname $0)/creyes.zsh" "$HOME/.oh-my-zsh/custom"

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

	# Check that the custom directory was set up
	set +e;
	ls $HOME/.oh-my-zsh/custom;
	has_issue=$?;
	set -e;

	if [ "$custom_dir" -ne 0 ];
		echo $custom_dir;
		return $custom_dir;
	fi

	# TODO: Check that the appropriate files were linked from that custom directory

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

	setup_zsh;

	return 0;
}

main "$@";
