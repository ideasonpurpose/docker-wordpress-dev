#!/bin/bash

#
# Check whether key is valid. This is passed into the container as a
# Docker secret. Docker-compose loads a key from the path specified
# in the .env file. SSH is pre-configured to use this key.
#
if (! ssh-keygen -l -f /run/secrets/SSH_KEY); then
  echo "Invalid key, unable to connect."
  exit 1
fi

#
# Try to split the $SSH_LOGIN string into $_USER, $_HOST and $_PORT
#
if [[ $SSH_LOGIN =~ ([^ @]+)@([^ ]+)( +-p +([0-9]+))?$ ]]; then
  echo "Parsing $SSH_LOGIN"
  _USER=${BASH_REMATCH[1]}
  _HOST=${BASH_REMATCH[2]}
  _PORT=${BASH_REMATCH[3]:-22}
else
  echo "Unable to parse SSH_LOGIN $SSH_LOGIN"
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
fi

#
# Exit if the necessary vars are not set
#
if [[ -z $_USER ]]; then
  echo "Unable to set USER"
  exit 1
fi
if [[ -z $_HOST ]]; then
  echo "Unable to set HOST"
  exit 1
fi
if [[ -z $_HOST ]]; then
  echo "Unable to set WP_CONTENT"
  exit 1
fi

#
# Sync down the remote database dumpfile
# TODO: This path is WP Engine specific
# TODO: Kinsta does not automatically provide a dumpfile in wp-content
#       BUT they do let us use cron, so we can create our own. Their nginx
#       proxy correctly services 403-forbidden responses to *.sql requests
#
if [[ "$1" == database ]]; then
  echo "Pulling new dumpfile from remote."
  rsync -azphv -e "ssh -p $_PORT" "${_USER}@${_HOST}:${_WP_CONTENT}/mysql.sql" /usr/src/site/_db/
fi

#
# Sync down the remote wp-content/plugins directory
#
if [[ "$1" == plugins ]]; then
  echo "Syncing plugins from remote."
  rsync -azphv -e "ssh -p $_PORT" "${_USER}@${_HOST}:${_WP_CONTENT}/plugins/" /usr/src/site/wp-content/plugins/
fi

#
# Sync down the remote wp-content/uploads directory
#
if [[ "$1" == uploads ]]; then
  echo "Syncing uploads from remote."
  rsync -azphv -e "ssh -p $_PORT" "${_USER}@${_HOST}:${_WP_CONTENT}/uploads/" /usr/src/site/wp-content/uploads/
fi
