#!/bin/bash

# This is a WordPress specific boilerplate assembler
# After running this script, the target directory will be fully configured for local WordPress
# development with tooling and copy of our wordpress theme boilerplate.
#
# Run permissions.sh after this to ensure correct file ownership and permissions
#
# This can also be run on an existing project to update or refresh tooling and dependencies.

# style helpers
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
CYAN="\033[36m"
GREEN="\033[32m"
GOLD="\033[33m"
CLEAR="\033[K"

# Progress/Done icons
DO="\r${GOLD}${BOLD}⋯${RESET} "
DONE="\r${GREEN}${BOLD}√${RESET} "

# Honestly, kind of amazed this $OWNER_GROUP trick works. The command stores the UID:GID from `stat`
# in a variable which is passed as the first argument to `chown` later on. Values are collected
# from the directory Docker's volume mount points to, on macOS and Windows the owner will usually
# be root, but on Linux it will match the active host user.
OWNER_GROUP=$(stat -c "%u:%g" /usr/src/site)

echo -ne "${DO}Resetting permissions "

# This is intentionally granular for files outside of the theme directory
chown -f "$OWNER_GROUP" \
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
    chown "$OWNER_GROUP" "/usr/src/site/${f}"
    chmod g+w "/usr/src/site/${f}"
done

chown -fR "$OWNER_GROUP" \
    /usr/src/site/_db \
    "/usr/src/site/wp-content"

chmod -fR ug+rwx /usr/src/site/_db

chmod -fR 0775 /usr/src/site/wp-content

find /usr/src/site/wp-content -type f -exec chmod -f 0664 {} \+

sleep 0.2s
echo -e "${DONE}Resetting permissions${CLEAR}"
