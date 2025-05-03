#!/bin/bash

# This script is a part of the ideasonpurpose/docker-wordpress-dev project
# https://github.com/ideasonpurpose/docker-wordpress-dev
#
# Version: 1.7.5

# Getting Started message

# style helpers
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
CYAN="\033[36m"
GREEN="\033[32m"
GOLD="\033[33m"
MAGENTA="\033[35m"
# CLEAR="\033[K"

# Progress/Done icons
DO="\r${GOLD}${BOLD}⋯${RESET} "
DONE="\r${GREEN}${BOLD}√${RESET} "

echo
echo -e "${BOLD}${MAGENTA}♥︎${RESET} Run this command to configure your local environment:"
echo
echo -e "${BOLD}${GOLD}   npm run bootstrap${RESET}"
echo
