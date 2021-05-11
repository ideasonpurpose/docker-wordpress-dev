#!/bin/bash

# This script corrects permissions of known files in our WordPress boilerplate.
# The script is run from Docker as root, with a $OWNER_GROUP envvar set to "$UID:$GID"
# Default values for $ID are

if [[ -z $OWNER_GROUP ]]; then
  # Honestly, kind of amazed this $OWNER_GROUP trick works. The command stores the UID:GID from `stat`
  # in a variable which is passed as the first argument to `chown` later on. Values are collected
  # from the directory Docker's volume mount points to, on macOS and Windows the owner will usually
  # be root, but on Linux it will match the active host user.
  OWNER_GROUP=$(stat -c "%u:%g" /usr/src/site)
fi

# style helpers
RESET="\033[0m"
BOLD="\033[1m"
# RED="\033[31m"
# CYAN="\033[36m"
GREEN="\033[32m"
GOLD="\033[33m"
CLEAR="\033[K"

# Progress/Done icons
DO="\r${GOLD}${BOLD}⋯${RESET} "
DONE="\r${GREEN}${BOLD}√${RESET} "

echo -ne "${DO}Resetting permissions "

echo -ne "${DO}Resetting permissions: Tooling files Ownership "

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
  /usr/src/site/README.md

echo -ne "${DO}Resetting permissions: Tooling files Permissions "
chmod -f g+w \
  /usr/src/site \
  /usr/src/site/.gitignore \
  /usr/src/site/.stylelintrc.js \
  /usr/src/site/composer.json \
  /usr/src/site/composer.lock \
  /usr/src/site/ideasonpurpose.config.js \
  /usr/src/site/package.json \
  /usr/src/site/package-lock.json \
  /usr/src/site/README.md

echo -ne "${DO}Resetting permissions: Boilerplate "
TOOLING=$(ls /usr/src/boilerplate-tooling)
for f in $TOOLING; do
  chown "$OWNER_GROUP" "/usr/src/site/${f}"
  chmod g+w "/usr/src/site/${f}"
done

echo -ne "${DO}Resetting permissions: Database "
chown -fR "$OWNER_GROUP" /usr/src/site/_db
chmod -fR ug+rwx /usr/src/site/_db

echo -ne "${DO}Resetting permissions: wp-content Permissions & Ownership: chmod "
chown "$OWNER_GROUP" "/usr/src/site/${f}"
chmod -fR 0664 /usr/src/site/wp-content
# Reset wp-content permissions or we'll be locked out of subsequent modifications
chmod -f 0775 /usr/src/site/wp-content

echo -ne "${DO}Resetting permissions: wp-content Permissions & Ownership: find: type d "
find /usr/src/site/wp-content -type d -exec chown -f "$OWNER_GROUP" {} \+ -exec chmod -f 0775 {} \+

sleep 0.2s
echo -e "${DONE}Resetting permissions${CLEAR}"
