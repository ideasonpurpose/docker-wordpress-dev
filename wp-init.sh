#!/bin/bash

# TODO: Should this script have a different name? Install? Init? Bootstrap?

# This is a WordPress specific boilerplate assembler
# After running this script, the target directory will contain
# A functional skeleton WordPress site with tooling

# style helpers
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
CYAN="\033[36m"
GOLD="\033[33m"

# Default vars
# DEFAULT_NAME=theme-name

echo -e ">>>  ${BOLD}${GOLD}IN WP-INIT.SH script${RESET}"

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

echo "Copying docker-compose and tooling files to project root"
cp -R /usr/src/boilerplate-tooling/* /usr/src/site/
cp -R /usr/src/boilerplate-tooling/.* /usr/src/site/


echo "Copying theme boilerplate to wp-content/themes/${NAME}"
mkdir -p /usr/src/site/wp-content/themes/${NAME}
cp -R /usr/src/boilerplate-theme/* /usr/src/site/wp-content/themes/${NAME}


echo "Creating theme directories in wp-content/themes/${NAME}"
mkdir -p /usr/src/site/wp-content/themes/${NAME}/{src,dist,lib,acf-json};
mkdir -p /usr/src/site/wp-content/themes/${NAME}/src/{js,sass,blocks,fonts,favicon,images};
mkdir -p /usr/src/site/wp-content/themes/${NAME}/lib/{CPT,Taxonomy,Widgets,blocks};


# Check for package.json to merge into
# if there isn't, create a boilerplate file and merge into that
if [[ ! -f /usr/src/site/package.json ]]; then
    echo "Creating baseline package.json file"
    echo '{"name": "${NAME}"}' >/usr/src/site/package.json
fi

# TODO: Not working
echo "Merging default scripts into package.json"
jq -s '.[0] + {scripts: (.[0].scripts + .[1].scripts)}' /usr/src/site/package.json /usr/src/package.json > /usr/src/site/package.json

echo "Creating default config file"
cp /usr/src/default.config.js /usr/src/site/ideasonpurpose.config.js

echo "Updating metadata in theme stylesheet";
sed -e "s/Theme Name.*$/Theme Name:         ${NAME}/" /usr/src/boilerplate-theme/style.css > /usr/src/site/wp-content/themes/${NAME}/style.css

echo "Updating directories in composer.json";
sed -e "s%wp-content/themes/THEME_NAME%wp-content/themes/${NAME}%" /usr/src/boilerplate-tooling/composer.json > /usr/src/site/composer.json
