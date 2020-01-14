#!/bin/bash

# TODO: Should this script have a different name? Install? Init? Bootstrap?

# This is a WordPress specific boilerplate assembler
# After running this script, the target directory will contain
# A functional skeleton WordPress site with tooling

SRC=/usr/src
SITE=/usr/src/site

# style helpers
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
CYAN="\033[36m"
GOLD="\033[33m"

# echo -e ">>>  ${BOLD}${GOLD}IN WP-INIT.SH script${RESET}"

# Load an existing .env file if it exists
if [[ -f /usr/src/site/.env ]]; then
    . /usr/src/site/.env
fi

# Try to set NAME to either NAME or npm_package_name (if run from an npm script)
NAME=${NAME:-${npm_package_name}}

if [[ -z $NAME ]]; then
    if [[ -f /usr/src/site/.env ]]; then
        echo 'Please set NAME in your .env file'
        exit 1
    else
        # No .env file, prompt for a name and write the file!

        # Check if we're in a TTY then prompt for a name
        if [[ ! -t 1 ]]; then
            echo 'This script is not running in a TTY terminal, please add `-t` if running from Docker'
            exit 1
        fi

        while true; do
            read -p "$(echo -e "\n${BOLD}${GOLD}Enter a theme name > ${RESET}${CYAN}")" INPUT
            echo -e -n $RESET

            if [[ "$INPUT" =~ ^[-_a-zA-Z0-9]+$ ]]; then
                # echo "'${INPUT}' is clean! (length ${#INPUT})"
                echo
                NAME=${INPUT}
                break
            fi

            echo -e "${RED}'${INPUT}' is not a valid name.${RESET}"
            echo "Names can only use letters, numbers and hyphens. Womp womp."
        done
    fi
fi

# TODO: Switch these to rsync so they don't stomp on existing subdirs
echo "Copying docker-compose and tooling files to project root"
cp -R /usr/src/boilerplate-tooling/. /usr/src/site

echo "Copying theme boilerplate to wp-content/themes/${NAME}"
mkdir -p /usr/src/site/wp-content/themes/${NAME}
cp -R /usr/src/boilerplate-theme/* /usr/src/site/wp-content/themes/${NAME}

echo "Creating theme directories in wp-content/themes/${NAME}"
mkdir -p /usr/src/site/wp-content/themes/${NAME}/{src,dist,lib,acf-json}
mkdir -p /usr/src/site/wp-content/themes/${NAME}/src/{js,sass,blocks,fonts,favicon,images}
mkdir -p /usr/src/site/wp-content/themes/${NAME}/lib/{CPT,Taxonomy,Widgets,blocks}

echo "Creating a .env file"
echo -e "NAME=${NAME}\n" >/usr/src/site/.env

echo "Creating default config file"
cp /usr/src/default.config.js /usr/src/site/ideasonpurpose.config.js

# Check for package.json to merge into or create one from boilerplate
# copy package.json to /tmp so jq doesn't overwrite the file we're working on
if [[ -f /usr/src/site/package.json ]]; then
    echo "Creating package.json tempfile"
    cp /usr/src/site/package.json /tmp/package.json
else
    echo "Creating baseline package.json file"
    jq -n '{name: "'${NAME}'", versionFiles: ["wp-content/themes/'${NAME}'/style.css"]}'  | cat >/tmp/package.json
    # echo -e '{"name": "'${NAME}'", "version_files": ["'${NAME}'"] }' >/tmp/package.json
fi

echo "Merging defaults onto package.json"
# jq -s '.[0] * (.[1] | {scripts, devDependencies, version_files, prettier})' /tmp/package.json /usr/src/package.json | cat >/usr/src/site/package.json
# jq -s '.[0] * (.[1] | {scripts, devDependencies, version_files, prettier}) | {., vvvv: 1234}' /tmp/package.json /usr/src/package.json | cat >/usr/src/site/package.json
jq -s '.[0] * (.[1] | {config, scripts, devDependencies, prettier}) + {versionFiles: [.[].versionFiles] | flatten | unique}' /tmp/package.json /usr/src/package.json | cat >/usr/src/site/package.json

echo "Updating metadata in theme stylesheet"
sed -e "s/Theme Name.*$/Theme Name:         ${NAME}/" /usr/src/boilerplate-theme/style.css >/usr/src/site/wp-content/themes/${NAME}/style.css

echo "Updating directories in composer.json"
sed -e "s%wp-content/themes/THEME_NAME%wp-content/themes/${NAME}%" /usr/src/boilerplate-tooling/composer.json >/usr/src/site/composer.json
