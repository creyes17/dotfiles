#!/bin/bash

# Enable unofficial "Strict mode"
set -euo pipefail;
IFS=$'\n\t';

# Exit Codes
readonly e_invalid_input=1;
readonly e_no_tmp_file=2;

usage() {
	cat <<-USAGE
		Description of what this script does.

		usage: $0 -r specific_required_argument [-o some_optional_argument] [-h]
		    -r specific_required_argument   Description of how this argument changes script behaviour
		    -h                              Display this help text and return
		    -o some_optional_argument       Description of how this argument changes script behaviour
		                                    (Defaults to "DEFAULT_VALUE")

		Relevant Environment Variables
		    GL_FOO                          Description of how this environment variable changes script behaviour

		Side Effects
		    Notes about any environment variables that are set or manipulated, files that are created or modified, etc.
		    Basically anything that happens that is not just printed to STDOUT

		Exit Codes
		    $e_invalid_input                               Invalid input code
		    $e_no_tmp_file                               Unable to create temporary file
USAGE
}

readonly tmp_filename=$(mktemp -t "$(basename $0)-$$-user-properties-bak.XXXXXXXX") || exit $e_no_tmp_file;

#=== FUNCTION ================================================================
# NAME: cleanup
# DESCRIPTION: Deletes temporary files. Should be called when script exits
# PARAMETERS: None.
# ENVIRONMENT VARIABLES: None.
# DEPENDENCIES: None.
# SIDE EFFECTS: None.
# EXIT CODES: None.
#=============================================================================
cleanup() {
	rm $tmp_filename;
	return 0;
}
trap cleanup EXIT;

main() {
	# IF and only if your script takes exactly one argument,
	# set it to a variable here using a default value
	#if [[ $# -ne 1 ]]; then
	#    usage;
	#    return 0;
	#fi
	#local environment=${$1:-development};

	# Normally use getopts instead. Declare all your variables before you set them.
	local required=;
	local optional="DEFAULT_VALUE";
	while getopts "r:ho:" opt; do
		case $opt in
			r)
				required="$OPTARG";
				;;
			h)
				usage;
				return 0;
				;;
			o)
				optional="$OPTARG";
				;;
			*)
				echo "Invalid argument!" >&2
				usage;
				return $e_invalid_input;
		esac;
	done;

	if [[ -z "$required" ]]; then
		echo "Missing required argument: -r" >&2;
		usage;
		return $e_invalid_input;
	fi

	echo "It's a good thing you gave me [$required] because that was required." > $tmp_filename;
	[[ -n "$optional" ]] && echo "Thanks for also giving me [$optional]! That was nice of you." >> $tmp_filename;

	cat $tmp_filename;

	return 0;
}

main "$@";
