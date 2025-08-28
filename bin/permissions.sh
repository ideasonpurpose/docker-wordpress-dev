#!/bin/bash

# This script is a part of the ideasonpurpose/docker-wordpress-dev project
# https://github.com/ideasonpurpose/docker-wordpress-dev
#
# Version: 1.7.8

# This script corrects permissions of known files in our WordPress boilerplate.
# The script is run from Docker as root, with a $OWNER_GROUP envvar set to "$UID:$GID"
# Default values for $ID are

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

if [[ -z $OWNER_GROUP ]]; then
  # Honestly, kind of amazed this $OWNER_GROUP trick works. The command stores the UID:GID from `stat`
  # in a variable which is passed as the first argument to `chown` later on. Values are collected
  # from the directory Docker's volume mount points to, on macOS and Windows the owner will usually
  # be root, but on Linux it will match the active host user.

  echo -e "${GOLD}DEPRECATED: ${BOLD}\$OWNER_GROUP${RESET}${GOLD} should be defined in the environment, or from docker-compose.${RESET}"
  echo -e "${GOLD}            Falling back to internal definition. This run will fail if \`/usr/src/site\` does not exist. (permissions.sh)${RESET}"

  OWNER_GROUP=$(stat -c "%u:%g" /usr/src/site)
fi

echo
echo -e "${GOLD}${BOLD}Resetting permissions${RESET}"

# This list is intentionally granular for files outside of the theme directory
TOP_LEVEL_FILES=(
  /usr/src/site/.env
  /usr/src/site/.env.sample
  /usr/src/site/.gitignore
  /usr/src/site/.stylelintrc.js
  /usr/src/site/composer.json
  /usr/src/site/composer.lock
  /usr/src/site/ideasonpurpose.config.js
  /usr/src/site/package.json
  /usr/src/site/package-lock.json
  /usr/src/site/README.md
)

for f in "${TOP_LEVEL_FILES[@]}"; do
  echo -ne "${DO}${GOLD} Resetting permissions: Top-level tooling files: ${CYAN}${f}${CLEAR}\r"
  chown -f "${OWNER_GROUP}" "${f}"
  chmod -f 0664 "${f}"
  sleep 0.1s
done
echo -e "${DONE} Top-level tooling files${CLEAR}"
sleep 0.2s

# echo -ne "${DO}Resetting permissions: Boilerplate tooling "
TOOLING=$(ls -C /usr/src/boilerplate-tooling)
find /usr/src/boilerplate-tooling -type f -printf "%P\n" | while read f; do
  echo -ne "${DO}${GOLD} Resetting permissions: Boilerplate tooling: ${CYAN}${f}${CLEAR}\r"
  chown -f "${OWNER_GROUP}" "/usr/src/site/${f}"
  chmod -f 0664 "/usr/src/site/${f}"
  sleep 0.2s
done
echo -e "${DONE} Boilerplate tooling${CLEAR}"
sleep 0.2s

echo -ne "${DO}${GOLD} Resetting permissions: Database files${CLEAR}\r"
chown -fR "${OWNER_GROUP}" /usr/src/site/_db
chmod -fR ug+rwx /usr/src/site/_db
echo -e "${DONE} Database files${CLEAR}"
sleep 0.2s

echo -ne "${DO}${GOLD} Resetting permissions: Webpack cache & debug files${CLEAR}\r"
chown -fR "${OWNER_GROUP}" /usr/src/site/webpack
chmod -fR 777 /usr/src/site/webpack
echo -e "${DONE} Webpack cache & debug files${CLEAR}"
sleep 0.2s

echo -ne "${DO}${GOLD} Resetting permissions: wp-content Permissions${CLEAR}}\r"
chmod -fR 0664 /usr/src/site/wp-content
# Reset wp-content permissions or we'll be locked out of subsequent modifications
chmod -f 0775 /usr/src/site/wp-content
echo -e "${DONE} wp-content Permissions & Ownership${CLEAR}"
sleep 0.2s

echo -ne "${DO}${GOLD} Resetting permissions: wp-content Permissions & Ownership: find: type d "
find /usr/src/site/wp-content -type d -exec chown -f "$OWNER_GROUP" {} \+ -exec chmod -f 0775 {} \+
echo -e "${DONE} wp-content Ownership${CLEAR}"
sleep 0.2s

# We don't know the theme name, so this just creates and updates any acf-json directories currently
# in this environment's wp-content directory.
echo -ne "${DO}${GOLD} Resetting permissions: acf-json Permissions & Ownership "
find /usr/src/site/wp-content/themes -maxdepth 1 -mindepth 1 -type d -exec mkdir -p {}/acf-json \;
find /usr/src/site/wp-content/themes -type f -wholename '*acf-json/*.json' -exec chmod -f 0664 {} \+
find /usr/src/site/wp-content/themes -type d -wholename '*acf-json' -exec chmod -f 0775 {} \;
find /usr/src/site/wp-content/themes -type d -wholename '*acf-json' -exec chown -Rf "$OWNER_GROUP" {} \;
echo -e "${DONE} acf-json Permissions & Ownership${CLEAR}"
sleep 0.2s

echo -e "${DONE}${GREEN} Done!${RESET}"
