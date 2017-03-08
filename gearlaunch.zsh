### Environment Variables ###

export GLHOME="$HOME/github/GearLaunch/hub";
export GLPORT=7432;
export GLPORTSECURE=7433;

export GLUSERNAME="chris_reyes";
export GLHOST="mole.gearint.com";

# Used in sbt, for example in vendor-timberline
export SPRING_PROFILES_ACTIVE="development";

# Make some further updates to my PATH for work
export PATH="$PATH:$HOME/bin/google-cloud-sdk/bin:$GLHOME/node_modules/.bin:$HOME/Library/Google/appengine-java-sdk/bin";

# Useful functions

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

# Loads the postgres database for the given environment
function glpostgres {
	local pgpassfile=;

	if [ -z "$PGPASSFILE" ]; then
		local pgpassfile="$HOME/.pgpass";
	else
		local pgpassfile=$PGPASSFILE;
	fi

	local yamldir="$GLHOME/src/main/resources";

	local dev="application-dev.yml";
	local prod="application-prod.yml";
	local sandbox="application-sandbox.yml";

	local require_auth=true;
	local ymlfile=;

	case $1 in
		sand|sandbox)
			local require_auth=false;
			local ymlfile=$sandbox
			;;
		dev)
			local require_auth=false;
			local ymlfile=$dev;
			;;
		prod)
			local ymlfile=$prod;
			;;
		*)
			local ymlfile="application-$1.yml";
			if [ ! -e "$yamldir/$ymlfile" ]; then
				echo "Unsupported environment! $1";
				return 1;
			fi
			;;
	esac

	local config=$(grep -A5 "postgres" "$yamldir/$ymlfile");
	
	local quoted_value_regex='s/^.*\"\([^\"]*\)\".*/\1/p';

	local hostname=$(echo $config | sed -ne "/host/ $quoted_value_regex")
	local databasename=$(echo $config | sed -ne "/database/ $quoted_value_regex");
	local username=$(echo $config | sed -ne "/user/ $quoted_value_regex");
	local port=$(echo $config | sed -ne '/port/ s/^.*port: \([[:digit:]]*\)[[:space:]]*/\1/p');

	if [ $require_auth != true ]; then
		local password=$(echo $config | sed -ne "/password/ $quoted_value_regex");
	else
		echo "Not automatically loading password. If you're sure, you can use this:";
		echo $config | sed -ne "/password/ $quoted_value_regex";
	fi

	local args="-ab -d \"$databasename\" -h \"$hostname\" -p \"$port\"";

	if [ -n "$username" ]; then
		local args="$args -U \"$username\"";
		if [ -n "$password" ]; then
			local auth_string="$hostname:$port:$databasename:$username:$password";

			if [ ! -e $pgpassfile ]; then
				echo "Creating PGPASSFILE ($pgpassfile)";
				touch $pgpassfile;
				chmod 0600 $pgpassfile;
			fi

			local found=$(grep "$auth_string" $pgpassfile);
			if [ -z "$found" ]; then
				echo "Updating PGPASSFILE ($pgpassfile) to include this account";
				echo $auth_string >> $pgpassfile;
			fi
		fi
	fi

	eval "psql $args";
}

# Useful aliases
alias .bgl="source $HOME/.oh-my-zsh/custom/gearlaunch.zsh";
alias gltun="autossh -M $GLPORTSECURE -R ${GLPORT}:localhost:8080 -nNT ${GLUSERNAME}@${GLHOST}";
alias mole="ssh ${GLUSERNAME}@${GLHOST}";
alias pg-start="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start";
alias pg-stop="pg_ctl -D /usr/local/var/postgres stop";
alias vimgl="vim $HOME/.oh-my-zsh/custom/gearlaunch.zsh";
