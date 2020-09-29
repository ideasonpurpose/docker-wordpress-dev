#!/bin/bash

# This is a WordPress specific boilerplate assembler
# After running this script, the target directory will be fully configured for local WordPress
# development with tooling and copy of our wordpress theme boilerplate.
#
# This can also be run on an existing project to update or refresh tooling and dependencies.

# style helpers
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
CYAN="\033[36m"
GOLD="\033[33m"

# Honestly, kind of amazed this $USERGROUP trick works. The command stores the UID:GID from `stat`
# in a variable which is passed as the first argument to `chown` later on. Values are collected
# from the directory Docker's volume mount points to, on macOS and Windows the owner will usually
# be root, but on Linux it will match the active host user.
USERGROUP=$(stat -c "%u:%g" /usr/src/site)

# If package.json exists, extract 'name' with jq into $NAME and continue
if [[ -s /usr/src/site/package.json ]]; then
    NAME=$(jq -r '.name // empty' /usr/src/site/package.json)
    DESCRIPTION=$(jq -r '.description // empty' /usr/src/site/package.json)
fi

# If $NAME is not set, prompt the user
if [[ -z "$NAME" ]]; then

    # Check whether we're running in a TTY before trying to prompt a name
    if [[ ! -t 1 ]]; then
        echo 'This script is not running in a TTY terminal, please add `-t` if running from Docker'
        exit 1
    fi

    # Prompt for a new theme name
    while true; do
        read -p "$(echo -e -n "\n${BOLD}${GOLD}Enter a theme name > ${RESET}${CYAN}")" INPUT
        echo -e -n "$RESET"

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
        echo 'This script is not running in a TTY terminal, please add `-t` if running from Docker'
        exit 1
    fi

    # Prompt for a new project description
    read -p "$(echo -e -n "\n${BOLD}${GOLD}Project description > ${RESET}${CYAN}")" DESCRIPTION
    echo -e -n "$RESET"
fi

echo
echo -e "${BOLD}Setting up WordPress environment"
echo -e "${BOLD}Theme name: ${CYAN}${NAME}${RESET}"
echo

# Set umask so all created files and folders are group-writable
umask 0002

echo "Syncing docker-compose and tooling files"
rsync -aq /usr/src/boilerplate-tooling/ /usr/src/site/

echo "Refreshing .gitignore from https://gist.github.com/4f7518e0d04a82a3ca16"
curl -sL https://gist.githubusercontent.com/joemaller/4f7518e0d04a82a3ca16/raw > /usr/src/site/.gitignore

echo "Creating directories"
mkdir -p /usr/src/site/_db
mkdir -p /usr/src/site/wp-content/{plugins,uploads}

echo "Restoring bolerplate theme files from ideasonpurpose/wp-theme-boilerplate"
curl -Ls https://github.com/ideasonpurpose/wp-theme-boilerplate/tarball/master > /tmp/theme-boilerplate.tar
mkdir -p /tmp/theme-boilerplate
tar -xf /tmp/theme-boilerplate.tar -C /tmp/theme-boilerplate --strip-components=1
mkdir -p "/usr/src/site/wp-content/themes/${NAME}"
rsync -aq --ignore-existing --exclude 'README.md' /tmp/theme-boilerplate/ "/usr/src/site/wp-content/themes/${NAME}"

echo "Creating theme directories in wp-content/themes/${NAME}"
mkdir -p /usr/src/site/wp-content/themes/"${NAME}"/{src,dist,lib,acf-json}
mkdir -p /usr/src/site/wp-content/themes/"${NAME}"/src/{js,sass,blocks,fonts,favicon,images}
mkdir -p /usr/src/site/wp-content/themes/"${NAME}"/lib/{CPT,Taxonomy,Widgets,blocks}

if [ ! -s "/usr/src/site/ideasonpurpose.config.js" ]; then
    echo "Creating default config file"
    cp /usr/src/default.config.js /usr/src/site/ideasonpurpose.config.js
fi

# Check for package.json to merge into or create a new one from boilerplate-package.json
# use /tmp to prevent accidentally overwriting the existing file
if [[ -s /usr/src/site/package.json ]]; then
    echo "Creating package.json tempfile"
    cp /usr/src/site/package.json /tmp/package.json
else
    echo "Copying boilerplate-package.json to tempfile"
        cp /usr/src/boilerplate-package.json /tmp/package.json
fi

# This merge extracts the default scripts and then applies those onto
# any existing scripts as a last step. All other properties defer to
# existing values.
echo "Merging defaults into package.json"
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
    /usr/src/boilerplate-package.json /tmp/package.json | cat > /usr/src/site/package.json

# Check for composer.json to merge into or create a new one from boilerplate-composer.json
# use /tmp to prevent accidentally overwriting the existing file
if [[ -s /usr/src/site/composer.json ]]; then
    echo "Creating composer.json tempfile"
    cp /usr/src/site/composer.json /tmp/composer.json
else
    echo "Copying bolilerplate-composer.json to tempfile"
    cp /usr/src/boilerplate-composer.json /tmp/composer.json
fi

# This command also syncs .description and sorts .require and .repositories, and re-orders some keys
# Preferred order is: {name, description, author, authors, config, autoload, [everything else]}
# Null values will not be written.
echo "Merging defaults onto composer.json"
jq -s '.[0] * .[1] |
       .config."vendor-dir" = "wp-content/themes/'"${NAME}"'/vendor" |
       .autoload."psr-4"."IdeasOnPurpose\\" = ["wp-content/themes/'"${NAME}"'/lib"] |
       .name //= "ideasonpurpose/'"${NAME}"'" |
       .description = "'"${DESCRIPTION}"'" |
       .repositories |= sort_by(.url) |
       .require = (.require | to_entries | sort_by(.key) | from_entries) |
       {name, description, version, authors, config, autoload} * . |
       with_entries(select(.value))' \
    /usr/src/boilerplate-composer.json /tmp/composer.json | cat > /usr/src/site/composer.json

echo "Updating metadata in theme stylesheet"
sed -i -e "s/Theme Name.*$/Theme Name:         ${NAME} - v0.0.0/" "/usr/src/site/wp-content/themes/${NAME}/style.css"
sed -i -e "s/Description.*$/Description:        ${DESCRIPTION}/" "/usr/src/site/wp-content/themes/${NAME}/style.css"


# Create a README.md file if the file doesn't exist
if [[ ! -s /usr/src/site/README.md ]]; then
    echo "Creating README.md file"
    echo -e "# ${NAME}\n" > /usr/src/site/README.md
    echo -e '#### Version 0.0.0\n'  >> /usr/src/site/README.md
    echo -e "${DESCRIPTION}\n" >> /usr/src/site/README.md
fi

# This is intentionally granular for files outside of the theme directory
echo "Resetting permissions"
chown -f "$USERGROUP" \
    /usr/src/site \
    /usr/src/site/.gitignore \
    /usr/src/site/.stylelintrc.js \
    /usr/src/site/composer.json \
    /usr/src/site/composer.lock \
    /usr/src/site/ideasonpurpose.config.js \
    /usr/src/site/package.json \
    /usr/src/site/package-lock.json \
    /usr/src/site/README.md \

chmod -f g+w \
    /usr/src/site \
    /usr/src/site/.gitignore \
    /usr/src/site/.stylelintrc.js \
    /usr/src/site/composer.json \
    /usr/src/site/composer.lock \
    /usr/src/site/ideasonpurpose.config.js \
    /usr/src/site/package.json \
    /usr/src/site/package-lock.json \
    /usr/src/site/README.md \


TOOLING=$(ls /usr/src/boilerplate-tooling)
for f in $TOOLING; do
    chown "$USERGROUP" "/usr/src/site/${f}"
    chmod g+w "/usr/src/site/${f}"
done

chown -fR "$USERGROUP" \
    /usr/src/site/_db \
    "/usr/src/site/wp-content"

chmod -fR ug+rwx /usr/src/site/_db

chmod -fR 0775 /usr/src/site/wp-content
find /usr/src/site/wp-content -type f -exec chmod -f 0664 {} \+
