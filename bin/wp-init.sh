#!/bin/bash

# This script is a part of the ideasonpurpose/docker-wordpress-dev project
# https://github.com/ideasonpurpose/docker-wordpress-dev
#
# Version: 1.7.8

# This is a WordPress specific boilerplate assembler
# After running this script, the target directory will be fully configured for local WordPress
# development with tooling and copy of our wordpress theme boilerplate.
#
# This can also be run on an existing project to update or refresh tooling and dependencies.
#
# Run permissions.sh after this to ensure correct file ownership and permissions

# style helpers
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
CYAN="\033[36m"
GREEN="\033[32m"
GOLD="\033[33m"
# CLEAR="\033[K"

# Progress/Done icons
DO="\r${GOLD}${BOLD}⋯${RESET} "
DONE="\r${GREEN}${BOLD}√${RESET} "

# If package.json exists, extract 'name' with jq into $NAME and continue
if [[ -s /usr/src/site/package.json ]]; then
  NAME=$(jq -r '.name // empty' /usr/src/site/package.json)
  DESCRIPTION=$(jq -r '.description // empty' /usr/src/site/package.json)
  VERSION=$(jq -r '.version // "0.0.0"' /usr/src/site/package.json)
fi

# If $NAME is not set, prompt the user
if [[ -z "$NAME" ]]; then

  # Check whether we're running in a TTY before trying to prompt a name
  if [[ ! -t 1 ]]; then
    echo "This script is not running in a TTY terminal, please add '-t' if running from Docker"
    exit 1
  fi

  # Prompt for a new theme name
  while true; do
    read -r -p "$(echo -ne "\n${BOLD}${GOLD}Enter a theme name > ${RESET}${CYAN}")" INPUT
    echo -ne "$RESET"

    if [[ "$INPUT" =~ ^[-_a-zA-Z0-9]+$ ]]; then
      # Input is clean, continue with the new $NAME
      NAME=${INPUT}
      break
    fi

    echo -e "${RED}'${INPUT}' is not a valid name.${RESET}"
    echo "Names can only contain letters, numbers and hyphens."
  done
fi

# If $DESCRIPTION is not set, prompt the user
if [[ -z "$DESCRIPTION" ]]; then

  # Check whether we're running in a TTY before trying to prompt a name
  if [[ ! -t 1 ]]; then
    echo "This script is not running in a TTY terminal, please add '-t' if running from Docker"
    exit 1
  fi

  # Prompt for a new project description
  read -r -p "$(echo -ne "${BOLD}${GOLD}Project description > ${RESET}${CYAN}")" DESCRIPTION
  echo -ne "$RESET"
fi

echo
echo -e "${GOLD}${BOLD}Setting up WordPress environment${RESET}"
echo -e "  Theme name: ${CYAN}${NAME}${RESET}"
if [[ -n "$DESCRIPTION" ]]; then
  echo -e "  Description: ${CYAN}${DESCRIPTION}${RESET}"
fi
echo

# Set umask so all created files and folders are group-writable
umask 0002

echo -ne "${DO}Syncing docker-compose and tooling files"
rsync -aq --no-owner --no-group /usr/src/boilerplate-tooling/ /usr/src/site/
echo -e "$DONE"

echo -ne "${DO}Refreshing ${CYAN}.gitignore${RESET} from ${GOLD}https://gist.github.com/4f7518e0d04a82a3ca16"
curl -sL https://gist.githubusercontent.com/joemaller/4f7518e0d04a82a3ca16/raw >/usr/src/site/.gitignore
echo -e "$DONE"

echo -ne "${DO}Creating directories"
mkdir -p /usr/src/site/_db
mkdir -p /usr/src/site/wp-content/{plugins,uploads}
echo -e "$DONE"

echo -ne "${DO}Restoring bolerplate theme files from ${GOLD}ideasonpurpose/wp-theme-boilerplate"
curl -Ls https://github.com/ideasonpurpose/wp-theme-boilerplate/tarball/master >/tmp/theme-boilerplate.tar
mkdir -p /tmp/theme-boilerplate
tar -xf /tmp/theme-boilerplate.tar -C /tmp/theme-boilerplate --strip-components=1
mkdir -p "/usr/src/site/wp-content/themes/${NAME}"
rsync -aq --ignore-existing --exclude 'README.md' /tmp/theme-boilerplate/ "/usr/src/site/wp-content/themes/${NAME}"
sleep 0.2s
echo -e "$DONE"

echo -ne "${DO}Creating theme directories in ${CYAN}wp-content/themes/${NAME}"
mkdir -p /usr/src/site/wp-content/themes/"${NAME}"/{src,dist,lib,acf-json}
mkdir -p /usr/src/site/wp-content/themes/"${NAME}"/src/{js,sass,blocks,fonts,favicon,images}
mkdir -p /usr/src/site/wp-content/themes/"${NAME}"/lib/{CPT,Taxonomy,Widgets,blocks}
echo -e "$DONE"

if [ ! -s "/usr/src/site/ideasonpurpose.config.js" ]; then
  echo -ne "${DO}Creating default config file"
  cp /usr/src/default.config.js /usr/src/site/ideasonpurpose.config.js
  echo -e "$DONE"
fi

# Check for package.json to merge into or create a new one from boilerplate-package.json
# use /tmp to prevent accidentally overwriting the existing file
if [[ -s /usr/src/site/package.json ]]; then
  echo -ne "${DO}Creating ${CYAN}package.json${RESET} tempfile"
  cp /usr/src/site/package.json /tmp/package.json
else
  echo -ne "${DO}Copying ${CYAN}boilerplate-package.json${RESET} to tempfile"
  cp /usr/src/boilerplate-package.json /tmp/package.json
fi
sleep 0.2s
echo -e "$DONE"

# This merge extracts the default scripts and then applies those onto
# any existing scripts as a last step. All other properties defer to
# existing values.
echo -ne "${DO}Merging defaults into ${CYAN}package.json"
jq -s '.[0].scripts as $defaultScripts |
       .[0] * .[1] |
       .name = "'"${NAME}"'" |
       .description = "'"${DESCRIPTION}"'" |
       ."version-everything".files = (
           ."version-everything".files + ["wp-content/themes/'"${NAME}"'/style.css"] |
           unique |
           sort
        ) |
        .scripts *= $defaultScripts' \
  /usr/src/boilerplate-package.json /tmp/package.json | cat >/usr/src/site/package.json
sleep 0.2s
echo -e "$DONE"

echo -ne "${DO}Sorting ${CYAN}package.json${RESET}"
/usr/local/bin/sort-package-json /usr/src/site/package.json &>/dev/null
echo -e "$DONE"

# When package-lock.json file is missing, assume this is a new instance. Run
# npm install to create a new package-lock.json so the bootstrap script will
# run without complaining.
if [[ ! -s /usr/src/site/package-lock.json ]]; then
  # Get user and group from package.json
  OWNER_GROUP=$(stat -c '%u:%g' /usr/src/site/package.json)
  echo -ne "${DO}Missing ${CYAN}package-lock.json${RESET} file, running ${GOLD}npm install${RESET}"
  npm install --prefix /usr/src/site &>/dev/null
  echo -e "$DONE"

  echo -ne "${DO}Resetting permissions on ${CYAN}package-lock.json${RESET} and ${CYAN}node_modules${RESET}"
  chown -R $OWNER_GROUP /usr/src/site/package-lock.json /usr/src/site/node_modules/
  echo -e "$DONE"
fi

# Check for composer.json to merge into or create a new one from boilerplate-composer.json
# use /tmp to prevent accidentally overwriting the existing file
if [[ -s /usr/src/site/composer.json ]]; then
  echo -ne "${DO}Creating ${CYAN}composer.json${RESET} tempfile"
  cp /usr/src/site/composer.json /tmp/composer.json
else
  echo -ne "${DO}Copying ${CYAN}bolilerplate-composer.json${RESET} to tempfile"
  cp /usr/src/boilerplate-composer.json /tmp/composer.json
fi
echo -e "$DONE"

# This command also syncs .description and sorts .require and .repositories, and re-orders some keys
# Preferred order is: {name, description, author, authors, config, autoload, [everything else]}
# Null values will not be written.
echo -ne "${DO}Merging defaults onto ${CYAN}composer.json"
jq -s '.[0] * .[1] |
       .config."vendor-dir" = "wp-content/themes/'"${NAME}"'/vendor" |
       .autoload."psr-4"."IdeasOnPurpose\\" = ["wp-content/themes/'"${NAME}"'/lib"] |
       .name //= "ideasonpurpose/'"${NAME}"'" |
       .description = "'"${DESCRIPTION}"'" |
       if .repositories then .repositories |= sort_by(.url) else . end |
       .require = (.require | to_entries | sort_by(.key) | from_entries) |
       {name, description, version, authors, config, autoload} * . |
       with_entries(select(.value))' \
  /usr/src/boilerplate-composer.json /tmp/composer.json | cat >/usr/src/site/composer.json

echo -e "$DONE"

# Copy style.css to /tmp to prevent sed permissions errors creating temp files
echo -ne "${DO}Updating metadata in theme ${CYAN}style.css"
cp "/usr/src/site/wp-content/themes/${NAME}/style.css" "/tmp/style.css"
sed -i -e "s/Theme Name.*$/Theme Name:         ${NAME} - v${VERSION}/" "/tmp/style.css"
sed -i -e "s/Description.*$/Description:        ${DESCRIPTION}/" "/tmp/style.css"
sed -i -e "s/Version.*$/Version:            ${VERSION}/" "/tmp/style.css"
cat "/tmp/style.css" >"/usr/src/site/wp-content/themes/${NAME}/style.css"
echo -e "$DONE"

# Create a README.md file if the file doesn't exist
if [[ ! -s /usr/src/site/README.md ]]; then
  echo -ne "${DO}Creating ${CYAN}README.md${RESET} file"
  echo -e "# ${NAME}\n" >/usr/src/site/README.md
  echo -e '#### Version ${VERSION}\n' >>/usr/src/site/README.md
  echo -e "${DESCRIPTION}\n" >>/usr/src/site/README.md
  echo -e "$DONE"
fi
