#!/bin/bash

# This script is a part of the ideasonpurpose/docker-wordpress-dev project
# https://github.com/ideasonpurpose/docker-wordpress-dev
#
# Version: 0.9.4
#
# This script does a few things:
#
# 1. Fetch the list of stable WordPress versions from the wordpress.org API
#    and extract the latest version number.
# 2. Request that tag from DockerHub to check that the image exists.
#
# If the version has a matching tag on DockerHub:
# - Store the version in wp-version.json. The file is just something like this:
#       { "wordpress": "5.9.2" }
# - Update the WordPress base image in the Dockerfile.
# - Update the WordPress version in README.md.
# - Update the WordPress version in the boilerplate-tooling docker-compose files
#
# The wp-version.json file should be commited to Git. The push-to-dockerhub
# GitHub Action uses this file to generate tag names for the Docker Image.

# style helpers
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
GOLD="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"

echo -e "💫  Fetching releases from the ${CYAN}WordPress API${RESET}..."
wget -q -O- http://api.wordpress.org/core/stable-check/1.0 >/tmp/wp.json
echo -e "👀  Found ${CYAN}$(jq -r 'length' /tmp/wp.json)${RESET} releases"

# jq '{wordpress: (to_entries[] | select(.value == "latest").key)}' /tmp/wp.json >/app/wp-version.json
WP_LATEST=$(jq -r 'to_entries[] | select(.value == "latest").key' /tmp/wp.json)
# WP_LATEST=5.9 # debug: Known good
# WP_LATEST=5.8.111 # debug: Known bad
echo -e "🎁  Latest WordPress release is ${CYAN}${WP_LATEST}${RESET}"

echo -e "🔍  Checking DockerHub to see if ${CYAN}wordpress:${WP_LATEST}${RESET} tag exists..."
wget -q -O- "https://registry.hub.docker.com/v2/repositories/library/wordpress/tags/${WP_LATEST}/" >/tmp/dockerhub-check.json
if [[ ! -s /tmp/dockerhub-check.json ]]; then
  echo -e "⚠️   ${RED}Tag ${WP_LATEST} not found on DockerHub, unable to bump WordPress version.${RESET}"
  exit
fi
echo -e "🎉  It does!"

jq -n "{wordpress: \"${WP_LATEST}\"}" >/app/wp-version.json
echo -e "✏️   Writing $(jq -C -c '.' /app/wp-version.json) to ${GOLD}wp-version.json${RESET}" # shhh, we already wrote it

echo -e "✏️   Updating ${GOLD}Dockerfile${RESET} to ${CYAN}wordpress:${WP_LATEST}${RESET}"
sed -i "s/wordpress:.*-php8/wordpress:${WP_LATEST}-php8/" /app/Dockerfile

echo -e "✏️   Updating ${GOLD}README.md${RESET} to ${CYAN}v${WP_LATEST}${RESET}"
sed -E -i "s/currently\s+\*\*\[v[^\\]+\]/currently **[v${WP_LATEST}]/" /app/README.md
sed -E -i "s/^<\!-- WPVERSION -->- WordPress.+$/<\!-- WPVERSION -->- WordPress ${WP_LATEST}/" /app/README.md
sed -E -i "s/ideasonpurpose\/wordpress:[^ ]+ init$/ideasonpurpose\/wordpress:${WP_LATEST} init/" /app/README.md

echo -e "✏️   Updating ${GOLD}docker-compose.yml${RESET} (boilerplate) to ${CYAN}wordpress:${WP_LATEST}${RESET}"
sed -E -i "s/ideasonpurpose\/wordpress:[0-9.]+/ideasonpurpose\/wordpress:${WP_LATEST}/" /app/boilerplate-tooling/docker-compose.yml

# echo
# echo -e "💫  Fetching latest ${GOLD}ideasonpurpose/docker-build${RESET} tag from ${CYAN}DockerHub${RESET}..."
# # Note: jq grabs the THIRD item returned. The first is 'latest' and the second is only the major.minor version string. We want major.minor.patch
# DOCKER_LATEST=$(wget -q -O- https://registry.hub.docker.com/v2/repositories/ideasonpurpose/docker-build/tags | jq -r '.results[2]["name"]')

# echo -e "👀  Found tag ${CYAN}${DOCKER_LATEST}${RESET}"

# echo -e "✏️   Updating ${GOLD}boilerplate-tooling/docker-compose.yml${RESET} to ${CYAN}docker-build:${DOCKER_LATEST}${RESET}"
# sed -E -i "s/ideasonpurpose\/docker-build:[0-9.]+/ideasonpurpose\/docker-build:${DOCKER_LATEST}/" /app/boilerplate-tooling/docker-compose.yml

echo
echo -e "✅  All done!"
