#!/bin/bash

# TODO: Should this script have a different name? Install? Init? Bootstrap?

# This is a WordPress specific boilerplate assembler
# After running this script, the target directory will contain
# A functional skeleton WordPress site with tooling

# style helpers
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
GOLD="\033[33m"

# Default vars
# DEFAULT_NAME=theme-name

echo -e ">>>  ${BOLD}${GOLD}IN WP-INIT.SH script${RESET}"

echo "Copy docker-compose and tooling files to project root"
cp -R /usr/src/boilerplate-tooling/* /usr/src/site/

# Try to set NAME to either NAME or npm_package_name (if run from an npm script)
NAME=${NAME:-${npm_package_name}}

if [[ -z $NAME ]]; then
    echo 'NO NAME SET'
    if [[ -f /usr/src/site/.env ]]; then

        echo 'Please set NAME in your .env file'
        exit 1
    else
        # No .env file, prompt for a name and write the file!
        
        # Check if we're in a TTY then prompt for a name
        if [ -t 0 ]; then
            echo 'This script is not running in a TTY terminal, please add `-t` if running from Docker'
            exit 0
        fi

        while true; do
            read -p "$(echo -e "\n${BOLD}${GOLD}Enter a theme name > ${RESET}${CYAN}")" INPUT
            echo -e -n $RESET

            if [[ "$INPUT" =~ ^[-_a-zA-Z0-9]+$ ]]; then
                # echo "'${INPUT}' is clean! (length ${#INPUT})"
                NAME=${INPUT}
                break
            fi

            echo "'${INPUT}' is not a valid name."
            echo "Names can only use letters, numbers and hyphens. Womp womp."
        done
    fi
fi

echo "Creating theme directories in wp-content/themes/${NAME}"
mkdir -p /usr/src/site/wp-content/themes/${NAME}/src/{js,sass,blocks,fonts,favicon,images}
mkdir -p /usr/src/site/wp-content/themes/${NAME}/dist

# Check for package.json to merge into
# if there isn't, create a boilerplate file and merge into that
if [[ ! -f /usr/src/site/package.json ]]; then
    echo "Creating baseline package.json file"
    echo '{"name": "${NAME}"}' >/usr/src/site/package.json
fi

echo "Merging default scripts into package.json"
jq -s '.[0] + {scripts: (.[0].scripts + .[1].scripts)}' /usr/src/site/package.json /usr/src/package.json >/usr/src/site/package.json

# Copy ideasonpurpose.config.js file
cp /usr/src/default.config.js /usr/src/site/ideasonpurpose.config.js

# Replace `Theme Name` in wp-content/themes/.../style.css
# sed '2s/.*/replacement-line/' file.txt > new_file.txt
sed -e "s/Theme Name/Theme Name:         ${THEME_NAME}/" /usr/src/boilerplate-theme/style.css >/usr/src/site/wp-content/${THEME_NAME}/style.css
