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

    # Make sure GPG is able to ask for user passphrase
    export GPG_TTY=$(tty);

    ### Paths and Other Important Variables

    export PERLPATH="/usr/local/Cellar/perl/5.24.0_1";
    export ANDROID_HOME="$HOME/Library/Android/sdk"; #TODO: This is for Mac, but need this to also work for Ubuntu
    export GOPATH="$HOME/golang";
    export VIMHOME="$HOME/.vim";
    export NVM_DIR="$HOME/.nvm";

    export CHEAP_STASH_HOME="$HOME/tmp/cheap-stash";
    export DOTFILES_HOME="$HOME/github/creyes17/dotfiles";

    export PATH="$HOME/bin:/Applications/LilyPond.app/Contents/Resources/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$GOPATH/bin:$VIMHOME/bin:$PERLPATH/bin:$PATH";
    export PATH="$NVM_DIR/versions/node/v7.10.0/bin/npm:$PATH";
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH";

    # Use pyenv distributions of python before homebrew if installed
    export PATH="$HOME/.pyenv/shims/:$PATH"

    export EDITOR="vim -u NONE";

    export WINEARCH="win64";
    export WINEPREFIX="$HOME/.wine";

    ### Virtualenv wrapper setup
    if [ -f $(which virtualenvwrapper.sh) ]; then
        source $(which virtualenvwrapper.sh);
    else
        echo 'Note: virtualenvwrapper not installed. Install via pip';
    fi

    ### Useful Functions

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

    #=== FUNCTION ================================================================
    # NAME: gmm
    # DESCRIPTION: Git Merge Master. Pulls the latest from master and merges into the current git branch
    # PARAMETERS: None.
    # ENVIRONMENT VARIABLES: None.
    # DEPENDENCIES: git
    # SIDE EFFECTS: Pulls the latest from master. May result in merge conflicts
    # EXIT CODES: 1 if could not checkout a different branch
    #=============================================================================
    gmm() {
        local old_branch=$(get_git_branch);
        git checkout - || return 1;
        local old_previous_branch=$(get_git_branch);
        git checkout master;
        git pull;
        git checkout "$old_branch";
        git merge master;
        git checkout "$old_previous_branch";
        git checkout "$old_branch";
    }

    # Sets up default python version
    use_python () {
        local version=$1;
        local venv_home="$HOME/.venv";
        local venv_dir;

        if [ "$version" = "2" ]; then
            venv_dir="$venv_home/py2";
        else
            if [ "$version" = "3" ]; then
                venv_dir="$venv_home/py3";
            else
                if [ -d "$venv_home/$version" ]; then
                    venv_dir="$venv_home/$version";
                else
                    echo "The only supported python versions are 2 and 3 at this time." >&2;
                    echo 'Set up more with `virtualenv --python=[executable]` in the dotfiles/venv directory and update this function' >&2;
                    return 1;
                fi
            fi
        fi

        source $venv_dir/bin/activate;
    }

    #=== FUNCTION ================================================================
    # NAME: cstash
    # DESCRIPTION: Cheap Stash. Saves a copy
    # PARAMETERS: command  Tells cstash what to do with the file. Defaults to save
    #                      Options are list, save, apply, pop, delete, view, edit, or clear
    #             file     The file to work with
    # DEPENDENCIES: None.
    # ENVIRONMENT VARIABLES: CHEAP_STASH_HOME
    # SIDE EFFECTS: Could apply changes to local workspace and/or clobber files stashed with cstash
    # EXIT CODES: 1 - invalid number of arguments
    #             2 - invalid command
    #             3 - file does not exist in local directory
    #             4 - file does not exist in cheap stash
    #             5 - encountered unknown error
    #=============================================================================
    cstash() {
        if [ $# -gt 2 ]; then
            echo "Invalid number of arguments" >&2;
            echo $usage >&2;
            return 1;
        fi

        local cmd=$1;
        local file=$2;

        local usage="Usage: cstash {list|save|apply|pop|remove|delete|view|edit|clear} [file]";

        local stash_dir;
        local stash_file;
        local stash_file_exists=false;

        if [ -n "$file" ]; then
            stash_dir="${CHEAP_STASH_HOME}$(pwd)/$(dirname $file)";
            stash_file="$stash_dir/$(basename $file)";

            if [ -e "$stash_file" ]; then
                stash_file_exists=true;
            fi
        fi

        case "$cmd" in
            list)
                if [ -n "$file" ]; then
                    ls -la $stash_file;
                else
                    tree $CHEAP_STASH_HOME;
                fi
                ;;
            save)
                if [ -e "$file" ]; then
                    mkdir -p $stash_dir;
                    cp $file $stash_dir;
                else
                    echo "File [$file] not found!" >&2;
                    echo $usage >&2;
                    return 3;
                fi
                ;;
            apply)
                if $stash_file_exists; then
                    cp $stash_file $file;
                else
                    echo "File [$file] not found in stash" >&2;
                    echo $usage >&2;
                    return 4;
                fi
                ;;
            pop)
                if $stash_file_exists; then
                    mv $stash_file $file;
                    local error_code=$?;
                    if [ $error_code -ne 0 ]; then
                        echo "Unable to copy stashed file [$stash_file] to file [$file] and remove from stash" >&2;
                        echo "Encountered error code: $error_code" >&2;
                        return 5;
                    fi
                else
                    echo "File [$file] not found in stash" >&2;
                    echo $usage >&2;
                    return 4;
                fi
                ;;
            remove|delete)
                if $stash_file_exists; then
                    rm $stash_file;
                else
                    echo "File [$file] has already been removed from stash" >&2;
                    return 4;
                fi
                ;;
            view)
                if $stash_file_exists; then
                    view $stash_file;
                else
                    echo "File [$file] not found in stash" >&2;
                    echo $usage >&2;
                    return 4;
                fi
                ;;
            edit)
                if $stash_file_exists; then
                    vim $stash_file;
                else
                    echo "File [$file] not found in stash" >&2;
                    echo $usage >&2;
                    return 4;
                fi
                ;;
            clear)
                # Note: -q is a zsh argument. It looks for the first instance of a
                # question mark and saves the user response to a variable with that name.
                read -q "response?Are you sure you want to remove all files from stash? [y/n]   "
                echo;
                if [ "$response" = "y" ]; then
                    rm -r $CHEAP_STASH_HOME;
                    mkdir -p $CHEAP_STASH_HOME;
                else
                    echo "Okay, leaving stash alone";
                fi
                ;;
            *)
                echo "Invalid command [$cmd]" >&2;
                echo $usage >&2;
                return 2;
                ;;
        esac

        return 0;
    }

    #=== FUNCTION ================================================================
    # NAME: pytest
    # DESCRIPTION: Automatically runs python unit tests whenever the given files are updated
    # PARAMETERS: module - The python module containing the tests
    #             file   - The file that you're testing
    #             files  - Any additional files you want to watch
    # DEPENDENCIES: when-changed
    # ENVIRONMENT VARIABLES: None.
    # SIDE EFFECTS: None.
    # EXIT CODES: 1 - invalid number of arguments
    #             2 - invalid command
    #             3 - file does not exist in local directory
    #             4 - file does not exist in cheap stash
    #             5 - encountered unknown error
    #=============================================================================
    pytest() {
        local module="$1"
        local file="$2"
        shift 2

        if ! [[ "$file" =~ "\.py$" ]]; then
            echo "$0 only works with python files (*.py)"
            return 1
        fi

        local test_file="$file"
        if [[ "$test_file" =~ "_test\.py$" ]]; then
            file=$(echo $file | sed -ne 's/_test\.py$/.py/p')
        else
            test_file=$(echo $test_file | sed -ne 's/\.py$/_test.py/p')
        fi

        when-changed -s "$file" "$test_file" "$@" -c "clear; date; python -m unittest -v $module"

        return 0
    }

    #=== FUNCTION ================================================================
    # NAME: create-script
    # DESCRIPTION: Creates a bash script with the given name using a template.
    # PARAMETERS: name  - The name of the script to create
    # DEPENDENCIES: None.
    # ENVIRONMENT VARIABLES: None.
    # SIDE EFFECTS: None.
    # EXIT CODES: 1 - invalid number of arguments
    #=============================================================================
    create-script() {
        if [ $# -ne 1 ]; then
            echo "Expecting required argument: script name"
            return 1;
        fi

        local script_name="$1";
        cp $DOTFILES_HOME/bash-script-template.sh $1;
        chmod +x $1;

        return 0;
    }

    ### Aliases

    local zshcustom="$HOME/.oh-my-zsh/custom";

    alias .bp=". $zshcustom/creyes.zsh";
    alias .brc=". $zshcustom/creyes.zsh";
    alias .nvm=". $NVM_DIR/nvm.sh; nvm use --delete-prefix v7.6.0"
    alias cddot="cd $HOME/github/creyes17/dotfiles";
    alias ctags="$(brew --prefix)/bin/ctags";  # Note: This fails if brew is not installed
    alias f="fg";
    alias gd="git diff -w";
    alias gitup="git push --set-upstream origin \$(get_git_branch)";
    alias gitpu="echo 'Did you mean git push or gitup?'";
    alias gobuildandtest="go build; go install; go test";
    alias ipython="python -m IPython";
    alias j="jobs";
    alias untar="tar -zxvf ";
    alias vimbp="vim $zshcustom/creyes.zsh";
    alias vimbrc="vim $zshcustom/creyes.zsh";
    alias vimvrc="vim $HOME/.vimrc";
    alias whatismyip="dig +short myip.opendns.com @resolver1.opendns.com";
}
