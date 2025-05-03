#!/bin/bash

# This script is a part of the ideasonpurpose/docker-wordpress-dev project
# https://github.com/ideasonpurpose/docker-wordpress-dev
#
# Version: 1.7.5

# style helpers
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
# GREEN="\033[32m"
GOLD="\033[33m"
# BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
# CLEAR="\033[K"

# Progress/Done icons
# DO="\r${GOLD}${BOLD}⋯${RESET} "
# DONE="\r${GREEN}${BOLD}√${RESET} "
FAIL="\r${RED}${BOLD}×${RESET} "

if [[ -z $OWNER_GROUP ]]; then
  # Lifted from permissions.sh, used to ensure _db, uploads and plugins have correct ownership & permissions
  # NOTE: Definiing this variable in the script is a fallback and probably deprecated or only for testing.
  # The value should already be defined before this script is called. (eg. the docker call or in docker-compose)
  echo -e "${GOLD}DEPRECATED: ${BOLD}\$OWNER_GROUP${RESET}${GOLD} should be defined in the environment, or from docker-compose.${RESET}"
  echo -e "${GOLD}            Falling back to internal definition. This run will fail if \`/usr/src/site\` does not exist. (pull.sh)${RESET}"

  OWNER_GROUP=$(stat -c "%u:%g" /usr/src/site)
fi

#
# Check whether key is valid. This is passed into the container as a
# Docker secret. Docker-compose loads a key from the path specified
# in the .env file. SSH is pre-configured to use this key.
# NOTE: The default key name 'id_rsa' does not have to be an RSA key
#
if [[ -f /run/secrets/SSH_KEY ]]; then
  echo
  echo -e "🔑  ${GOLD}Copying key to /ssh_keys/id_rsa${RESET}"
  cp /run/secrets/SSH_KEY /ssh_keys/id_rsa
  chmod 0600 /ssh_keys/id_rsa
fi

if (! ssh-keygen -lv -f /ssh_keys/id_rsa); then
  echo
  echo -e "${FAIL}${RED}Invalid key, unable to connect.${RESET}"
  exit 1
fi

# Warn on RSA keys (no longer supported)
if grep -q "BEGIN RSA PRIVATE KEY" /ssh_keys/id_rsa; then
  echo
  echo -e "🗝️   ${RED}You're using a legacy RSA key. The ssh-rsa algorithm is no longer supported by${RESET}"
  echo -e "    ${RED}OpenSSH servers and connections will likely fail without meaningful warnings.${RESET}"
  echo
  echo -e "🚨  ${BOLD}Please update your SSH keys.${RESET}"
fi

#
# Try to split the $SSH_LOGIN string into $_USER, $_HOST and $_PORT
#
if [[ $SSH_LOGIN =~ ([^ @]+)@([^ ]+)( +-p +([0-9]+))?$ ]]; then
  echo
  echo -e "🤖  ${GOLD}Parsing ${MAGENTA}${SSH_LOGIN}${RESET}"
  echo
  _USER=${BASH_REMATCH[1]}
  _HOST=${BASH_REMATCH[2]}
  _PORT=${BASH_REMATCH[4]:-22}
else
  echo
  echo -e "${FAIL}Unable to parse SSH_LOGIN $SSH_LOGIN"
fi

#
# Override $_USER if $SSH_USER is set
#
if [[ -n "$SSH_USER" ]]; then
  _USER=${SSH_USER}
fi

#
# Override $_HOST if $SSH_HOST is set
#
if [[ -n "$SSH_HOST" ]]; then
  _HOST=${SSH_HOST}
fi

#
# Override $_PORT if $SSH_PORT is set
#
if [[ -n "$SSH_PORT" ]]; then
  _PORT=${SSH_PORT}
fi

#
# Set the path to wp-content if $SSH_WP_CONTENT_DIR is not set
if [[ -z "$SSH_WP_CONTENT_DIR" ]]; then
  _WP_CONTENT="sites/${_USER}/wp-content"
else
  _WP_CONTENT="${SSH_WP_CONTENT_DIR}"
fi

echo -e "        ${CYAN}_USER${RESET}: ${MAGENTA}${_USER}${RESET}"
echo -e "        ${CYAN}_HOST${RESET}: ${MAGENTA}${_HOST}${RESET}"
echo -e "        ${CYAN}_PORT${RESET}: ${MAGENTA}${_PORT}${RESET}"
echo -e "  ${CYAN}_WP_CONTENT${RESET}: ${MAGENTA}${_WP_CONTENT}${RESET}"

#
# Exit if the necessary vars are not set
#
if [[ -z $_USER ]]; then
  echo
  echo -e "${FAIL}Unable to set USER"
  exit 1
fi
if [[ -z $_HOST ]]; then
  echo
  echo -e "${FAIL}Unable to set HOST"
  exit 1
fi
if [[ -z $_PORT ]]; then
  echo
  echo -e "${FAIL}Unable to set PORT"
  exit 1
fi
if [[ -z $_WP_CONTENT ]]; then
  echo
  echo -e "${FAIL}Unable to set WP_CONTENT"
  exit 1
fi

#
# Sync down the remote database dumpfile
# The default DB path is based on WP Engine defaults. Kinsta does not automatically create dumpfiles
# in wp-content _but_ they do let us use cron, so we can create our own. Their nginx proxy correctly
# services 403-forbidden errors to *.sql requests.
#
if [[ "$1" == database ]]; then
  echo
  echo -e "📚  ${GOLD}Pulling new dumpfile from remote.${RESET}"
  echo
  mkdir -p /usr/src/site/_db
  chown -R "${OWNER_GROUP}" /usr/src/site/_db
  chmod -R g+w /usr/src/site/_db
  rsync -azhv -e "ssh -p ${_PORT}" "${_USER}@${_HOST}:${_WP_CONTENT}/mysql.sql" /usr/src/site/_db/
  chown -R "${OWNER_GROUP}" /usr/src/site/_db
  chmod -R g+w /usr/src/site/_db
fi

#
# Sync down the remote wp-content/plugins directory
#
if [[ "$1" == plugins ]]; then
  echo
  echo -e "🧩  ${GOLD}Pulling plugins from remote.${RESET}"
  echo
  mkdir -p /usr/src/site/wp-content/plugins
  chown -R "${OWNER_GROUP}" /usr/src/site/wp-content/plugins
  chmod -R g+w /usr/src/site/wp-content/plugins
  rsync -azhv -e "ssh -p ${_PORT}" "${_USER}@${_HOST}:${_WP_CONTENT}/plugins/" /usr/src/site/wp-content/plugins/
  chown -R "${OWNER_GROUP}" /usr/src/site/wp-content/plugins
  chmod -R g+w /usr/src/site/wp-content/plugins
fi

#
# Sync down the remote wp-content/uploads directory
# If second arg is "all" then download everything
# If second arg is a year-ish four-digit number then treat as a year and download that year
# If second arg is anything else or missing, then download the current year
#
if [[ "$1" == uploads ]]; then
  DIR="$(date +%Y)"
  LABEL="${DIR}"

  if [[ "$2" =~ ^[0-9]{4}$ ]]; then
    DIR="${2}"
    LABEL="$2"
  fi

  DIR="${DIR}/"

  if [[ "$2" == "all" ]]; then
    DIR=""
    LABEL="$2"
  fi

  echo
  echo -e "🖼   ${GOLD}Pulling ${LABEL} uploads from remote.${RESET}"
  echo
  mkdir -p "/usr/src/site/wp-content/uploads/${DIR}"
  chown -R "${OWNER_GROUP}" /usr/src/site/wp-content/uploads
  chmod -R g+w /usr/src/site/wp-content/uploads
  rsync -azhv -e "ssh -p $_PORT" "${_USER}@${_HOST}:${_WP_CONTENT}/uploads/${DIR}" "/usr/src/site/wp-content/uploads/${DIR}"
  chown -R "${OWNER_GROUP}" /usr/src/site/wp-content/uploads
  chmod -R g+w /usr/src/site/wp-content/uploads
fi
