### Environment Variables ###

export GLHOME="$HOME/github/GearLaunch/hub";
export GLPORT=7434;
export GLPORTSECURE=7435;

export GLUSERNAME="chris_reyes";
export GLHOST="mole.gearint.com";

# Used in sbt, for example in vendor-timberline
export SPRING_PROFILES_ACTIVE="development";

# Make some further updates to my PATH for work
export PATH="$PATH:$HOME/bin/google-cloud-sdk/bin:$GLHOME/hub-war/node_modules/.bin:$HOME/Library/Google/appengine-java-sdk/bin";

# Useful functions

# Get JIRA Ticket ID
# Given the branch, finds the jira ticket ID
function get_jira_id {
	local branch=$(get_git_branch);

	if [[ -z $branch ]]; then
		echo "Could not obtain a git branch" >&2;
		return;
	fi

	# Grab the first word and number combination and just assume that it's the ID
	local id=$(echo $branch | perl -ne "s/(^\w+-\d+)(-.*)$/\U\1/ && print");

	if [[ -z $id ]]; then
		echo "Git branch doesn't seem to contain a jira id" >&2;
		return;
	fi

	echo $id;
	return;
}

# Git commit
# Automatically prepends the jira task id to the beginning of the commit message
# Usage: 
function gitco {
	if [[ -z $1 ]]; then
		echo "Usage: gitco [commit message]" >&2;
		return
	fi

	local id=$(get_jira_id);

	if [[ -z $id ]]; then
		echo "Could not find JIRA ID. Skipping commit" >&2;
		return
	fi

	git commit -m "$id $@";
}

# Loads the postgres database for the given environment
function glpostgres {
	local pgpassfile=;

	if [ -z "$PGPASSFILE" ]; then
		local pgpassfile="$HOME/.pgpass";
	else
		local pgpassfile=$PGPASSFILE;
	fi

	local yamldir="$GLHOME/hub-war/src/main/resources/conf";

	local dev="application-dev.yml";
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
			psql -ab -d "hub" -h "paly2.gearint.com" -p "5432" -U "chris.reyes";
			return 0;
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

# Usage
# glcloud {dump|load|sql} {sandbox|dev|prod} {filename} {table-to-dump} [table-to-dump ...]
function glcloud {
	local cloudsql_user="chris.reyes";
	local ssl_home="$HOME/.ssl/gearlaunch";

	local host=;
	local ssl_dir=;
	local use_local=false;
	local database=;

	local mode="$1";
	local environment="$2";

	shift 2;

	local args=;

	case $environment in
		sand|sandbox)
			local ssl_dir="$ssl_home/gearlaunch-hub-sandbox";
			local host="35.188.207.94";
			local database="email_marketing_sandbox";
			;;
		dev|local)
			local use_local=true;
			local database="email_marketing_dev";
			;;
		prod)
			local ssl_dir="$ssl_home/gearlaunch-hub";
			local host="35.188.39.236";
			local database="email_marketing_production";
			;;
		*)
			echo "Unsupported environment! $environment";
			return 1;
			;;
	esac

	if ! $use_local; then
		local args="--user=$cloudsql_user --password --host=$host --ssl-ca=$ssl_dir/server-ca.pem --ssl-cert=$ssl_dir/client-cert.pem --ssl-key=$ssl_dir/client-key.pem";
	fi

	local cmd=;

	case $mode in
		dump)
			local filename="$1";
			shift;
			local tables="$*";
			local cmd="mysqldump --set-gtid-purged=OFF $args $database $tables > $filename";
			;;
		load)
			local filename="$1";
			local cmd="mysql $args $database < $filename";
			;;
		sql)
			local cmd="mysql $args $database";
			;;
		*)
			echo "Unrecognized command: [$mode]" >&2;
			echo "Usage: glcloud {dump|load|sql} {sandbox|dev|prod} [{filename} {table-to-dump} [table-to-dump ...]]" >&2;
			return 1;
			;;
	esac

	eval $cmd;
	return 0;
}

reset-local-datastore() {
	rm /var/tmp/local_db.bin /var/tmp/blobs;
}

reset-local-postgres() {
	(
		cd $GLHOME/hub-war;
		mvn flyway:clean flyway:migrate;
	)
}

reset-local-mysql() {
	(
		cd $GLHOME/email-marketing;
		mvn flyway:clean flyway:migrate;
	)
}

reset-local-dev-environment() {
	reset-local-datastore;
	reset-local-postgres;
	reset-local-mysql;
	clean-hub;
}

function base64urlencode {
	printf %s "$1" | base64 | perl -pe "chomp" | jq -s -R -r @uri;
}

function create-branch {
	read -r -d '' usage <<-USAGE
		Creates a new, appropriately named git branch and checks it out
		usage: $0 [story number] [name]
USAGE

	if [ $# -lt 2 ]; then
		echo $usage;
		return 0;
	fi

	local num=$1;
	if ! [[ $num =~ '^[[:digit:]]+$' ]]; then
		echo "Error: story number must only contain digits 0-9" >&2;
		echo >&2;
		echo $usage >&2;
		return 1;
	fi

	shift;
	local name=$(echo -n "$@" | sed -e 's/[[:space:]]\{1,\}/-/g' | awk '{ print tolower($0) }');
	local branch="dev-$num-$name";

	if [ -z "$($GLHOME/bin/validate-branch-name.sh $branch)" ] && [ $? -eq 0 ]; then
		# Validation successful
		git checkout -b $branch;
		return 0;
	fi

	echo "Error: name did not pass validation." >&2;
	echo >&2;
	echo $usage >&2;
	return 2;
}

# Cleans out and resets all the built files in the hub project
clean-hub() {
	# Run in a subshell so we don't affect the current directory stack
	(
		cd $GLHOME;
		mvn clean install -pl '!hub-war';
		cd hub-war;

		# Sometimes the node_modules directory remains, even though it's been cleaned out.
		# Remove it so that the package command will re-populate it
		if [ "$(ls node_modules | wc -l)" -eq 0 ]; then
			rm -r node_modules;
		fi

		mvn clean package -DskipTests;
	)
}

# Useful aliases
alias .bgl="source $HOME/.oh-my-zsh/custom/gearlaunch.zsh";
alias cb="create-branch";
alias gltun="autossh -M $GLPORTSECURE -R ${GLPORT}:localhost:8080 -nNT ${GLUSERNAME}@${GLHOST}";
alias gmd="git checkout develop; git pull; git checkout -; git merge develop;";
alias mole="ssh ${GLUSERNAME}@${GLHOST}";
alias pg-start="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start";
alias pg-stop="pg_ctl -D /usr/local/var/postgres stop";
alias vimgl="vim $HOME/.oh-my-zsh/custom/gearlaunch.zsh";
