#!/usr/bin/env bash

# Describes usage.
USAGE="Usage: visualizationPreprocessing.sh [-h] -g user/repo -i <path> [-i <path>]...

Description: Preprocessing steps for visualizing the history of 1 or more GitHub repositories.

Arguments:
-i --input		A git repo.
-g --github		The github repo (formatted as: "username/repository") to use for release information.
"

# Defines error echo.
errcho() { echo "$@" 1>&2; }

# Base path (to script).
readonly BASE_PATH=$(sed 's/visualizationPreprocessing.sh$//' <<< $0 | sed -e 's/^$/.\//g')

function main {
	echo "Digesting command line..."
	digestCommandLine $@
	echo "Preparing for data processing..."
	prepare
	echo "Processing git repositories..."
	processGitRepos
	echo "Retrieving releases from GitHub..."
	retrieveGitHubReleases
}

function digestCommandLine {
	# Checks if any arguments were given.
	if [ $# -eq 0 ]; then errcho "No arguments were given.\n\n$USAGE"; exit 1; fi

	# Array to store git repositories in.
	REPOS=()

	#Digests the command line arguments.
	while [[ $# -gt 0 ]]
	do
		key="$1"
		case $key in
			-i|--input)
			REPOS+=("$2")
			shift # argument
			shift # value
			;;
			-g|--github)
			GITHUB="$2"
			shift # argument
			shift # value
			;;
			-h|--help)
			HELP=TRUE
			shift # argument
			;;
			*)    # unknown option
			shift # argument
			;;
		esac
	done
}

function prepare {
	mkdir gource_input
	cd gource_input
}

function processGitRepos {
	# Creates logs for all input files.
	for REPO in ${REPOS[@]}
	do
		local REPO_NAME=${REPO##*/}
		local LOG_FILE="$REPO_NAME"'.txt'
		# Generates log.
		gource --output-custom-log "$LOG_FILE" "$REPO"
		# Adds custom root based on repository name.
		sed -i '' "s#\(.*|\)#\1/$REPO_NAME#g" "$LOG_FILE"
	done

	# Merges and sorts log files into a single file.
	cat *.txt | sort -n >> combined.txt

	# Prepends a ROOT node to the file.
	local ROOT_TIME=$(($(head -n 1 combined.txt | sed 's/|.*$//g') - 10000000))
	echo "$ROOT_TIME"'|ROOT|A|.ROOT' > combined_new.txt
	cat combined.txt >> combined_new.txt
	mv combined_new.txt combined.txt
}

function retrieveGitHubReleases {
	python3 "$BASE_PATH"retrieveGitHubReleases.py "$GITHUB" captions.txt
	sort -n -o captions.txt captions.txt
}

main $@