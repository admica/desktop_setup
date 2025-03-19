#!/bin/bash
# PATH: ./install.sh
# Installation Script

# Exit immediately on error
set -e

# Define color codes for better output readability
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

LOGFILE="/tmp/desktop_setup_$(date +%Y%m%d_%H%M%S).log"

print_header() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="[${timestamp}] ### $1 ###"
    echo -e "${GREEN}${message}${NC}"
    echo "$message" >> "$LOGFILE"
}

print_action() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="[${timestamp}] >>> $1"
    echo -e "${BLUE}${message}${NC}"
    echo "$message" >> "$LOGFILE"
}

print_error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="[${timestamp}] ERROR: $1"
    echo -e "${RED}${message}${NC}"
    echo "$message" >> "$LOGFILE"
}

print_detail() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="[${timestamp}]     $1"
    echo -e "${CYAN}${message}${NC}"
    echo "$message" >> "$LOGFILE"
}

print_header "Copy"
print_detail "copy .bash_prompt"
cp -f .bash_prompt ~/

print_header "Rsync"
print_detail "rsync .local -> ~/"
rsync -avzh ./.local/ ~/.local/

print_detail "rsync .config -> ~/"
rsync -avzh ./.local/ ~/.config/

print_header "Update font cache"
fc-cache -fv

print_header "Check .bashrc"
grep "bash_prompt" ~/.bashrc 2>/dev/null

if [[ $? -ne 0 ]]; then
    print_detail "adding source ~/.bash_prompt to ~/.bashrc"
    echo "source ~/.bash_prompt" >> ~/.bashrc
else
    print_detail "bash_prompt already called from .bashrc"
fi

print_header "Installation Complete!"
