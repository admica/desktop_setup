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
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Flags
DRY_RUN=false
IS_WSL=false

# Detect WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
fi

# Parse command line arguments
show_help() {
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be done without making changes"
    echo "  --help       Show this help message"
    echo ""
    echo "This script installs desktop configuration files including:"
    echo "  - Neovim (AppImage)"
    echo "  - Alacritty terminal config and themes"
    echo "  - Bash prompt with git integration"
    echo "  - Nerd Fonts (Fira Code, Go Mono)"
    echo "  - Vim configuration"
}

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            show_help
            exit 1
            ;;
    esac
done

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

print_dry_run() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="[${timestamp}] [DRY-RUN] Would: $1"
    echo -e "${YELLOW}${message}${NC}"
}

# Execute or print command based on DRY_RUN flag
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "$*"
    else
        "$@"
    fi
}

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}=== DRY RUN MODE - No changes will be made ===${NC}"
    echo ""
fi

print_header "Checking requirements"
print_detail "curl"
command -v curl >/dev/null 2>&1 || { print_error "curl is required but not installed."; exit 1; }

print_detail "rsync"
command -v rsync >/dev/null 2>&1 || { print_error "rsync is required but not installed."; exit 1; }

print_detail "fc-cache"
command -v fc-cache >/dev/null 2>&1 || { print_error "fontconfig is required but not installed."; exit 1; }
print_detail "Done"

# Install full vim with syntax highlighting (minimal vim packages lack +syntax)
install_full_vim() {
    if /usr/bin/vi --version 2>/dev/null | grep -q "+syntax"; then
        print_detail "Full vim with syntax support already installed."
        return 0
    fi

    if [ -f /etc/fedora-release ]; then
        print_header "Vim Setup (Fedora)"
        print_action "Installing vim-enhanced for syntax highlighting..."
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "sudo dnf install -y vim-enhanced"
        else
            sudo dnf install -y vim-enhanced
            print_detail "vim-enhanced installed."
        fi
    elif [ -f /etc/debian_version ]; then
        print_header "Vim Setup (Debian/Ubuntu)"
        print_action "Installing vim for syntax highlighting..."
        if [ "$DRY_RUN" = true ]; then
            print_dry_run "sudo apt-get install -y vim"
        else
            sudo apt-get install -y vim
            print_detail "vim installed."
        fi
    fi
}
install_full_vim

print_header "Neovim Setup"
if nvim --version >/dev/null 2>&1; then
    print_detail "Neovim is already installed."
else
    print_action "Neovim not found. Installing latest stable AppImage..."

    # Determine architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  NVIM_APPIMAGE="nvim-linux-x86_64.appimage" ;;
        aarch64) NVIM_APPIMAGE="nvim-linux-arm64.appimage" ;;
        *)       print_error "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/${NVIM_APPIMAGE}"

    if [ "$DRY_RUN" = true ]; then
        print_dry_run "mkdir -p ~/.local/bin"
        print_dry_run "curl -L -o /tmp/nvim.appimage $NVIM_URL"
        if [ "$IS_WSL" = true ]; then
            print_dry_run "Extract AppImage (WSL lacks FUSE support)"
            print_dry_run "Create wrapper script at ~/.local/bin/nvim"
        else
            print_dry_run "mv /tmp/nvim.appimage ~/.local/bin/nvim"
            print_dry_run "chmod u+x ~/.local/bin/nvim"
        fi
    else
        mkdir -p ~/.local/bin

        print_detail "Downloading $NVIM_APPIMAGE..."
        curl -L -o /tmp/nvim.appimage "$NVIM_URL"

        if [ $? -eq 0 ]; then
            print_detail "Download successful."
            chmod u+x /tmp/nvim.appimage

            if [ "$IS_WSL" = true ]; then
                # WSL lacks FUSE support, so extract the AppImage
                print_detail "Extracting AppImage (WSL lacks FUSE)..."
                (
                    cd /tmp
                    ./nvim.appimage --appimage-extract >/dev/null 2>&1
                    rm -rf ~/.local/nvim-appimage
                    mv squashfs-root ~/.local/nvim-appimage
                    rm /tmp/nvim.appimage
                )

                # Create wrapper script
                cat > ~/.local/bin/nvim << 'EOF'
#!/bin/bash
exec ~/.local/nvim-appimage/usr/bin/nvim "$@"
EOF
                chmod u+x ~/.local/bin/nvim
                print_detail "Installed extracted Neovim to ~/.local/nvim-appimage/"
            else
                # Native Linux - use AppImage directly
                mv /tmp/nvim.appimage ~/.local/bin/nvim
                print_detail "Installed to ~/.local/bin/nvim"
            fi

            export PATH="$HOME/.local/bin:$PATH"
        else
            print_error "Failed to download Neovim AppImage."
            exit 1
        fi
    fi
fi

print_header "Copy"
print_detail "copy .bash_prompt"
if [ "$DRY_RUN" = true ]; then
    print_dry_run "cp -f .bash_prompt ~/"
else
    cp -f .bash_prompt ~/
fi

print_detail "copy .vimrc"
if [ "$DRY_RUN" = true ]; then
    print_dry_run "cp -f .vimrc ~/"
else
    cp -f .vimrc ~/
fi

print_header "Rsync"
print_detail "rsync .local -> ~/"
if [ "$DRY_RUN" = true ]; then
    print_dry_run "rsync -avzh ./.local/ ~/.local/"
    rsync -avzhn ./.local/ ~/.local/ 2>/dev/null | head -20
else
    rsync -avzh ./.local/ ~/.local/
fi

print_detail "rsync .config -> ~/"
if [ "$DRY_RUN" = true ]; then
    print_dry_run "rsync -avzh ./.config/ ~/.config/"
    rsync -avzhn ./.config/ ~/.config/ 2>/dev/null | head -20
else
    rsync -avzh ./.config/ ~/.config/
fi

print_header "Fonts"
print_detail "Update font cache"
if [ "$DRY_RUN" = true ]; then
    print_dry_run "fc-cache -fv"
else
    fc-cache -fv
fi

print_header "Bashrc"
print_detail "Checking .bashrc"
if grep -q "bash_prompt" ~/.bashrc 2>/dev/null; then
    print_detail "bash_prompt found in .bashrc, skipping..."
else
    if [ "$DRY_RUN" = true ]; then
        print_dry_run "echo 'source ~/.bash_prompt' >> ~/.bashrc"
    else
        print_detail "adding source ~/.bash_prompt to ~/.bashrc"
        echo "source ~/.bash_prompt" >> ~/.bashrc
    fi
fi

if [ "$DRY_RUN" = true ]; then
    print_header "Dry Run Complete!"
    echo -e "${YELLOW}Run without --dry-run to apply changes${NC}"
else
    print_header "Installation Complete!"
fi

# WSL-specific instructions
if [ "$IS_WSL" = true ]; then
    echo ""
    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│  WSL DETECTED - Additional setup required for Nerd Font icons  │${NC}"
    echo -e "${YELLOW}└─────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo "  Windows Terminal uses Windows fonts, not Linux fonts."
    echo "  To see icons in your prompt (git, python, etc.):"
    echo ""
    echo "  1. Download a Nerd Font on Windows:"
    echo -e "     ${CYAN}https://www.nerdfonts.com/font-downloads${NC}"
    echo "     (Recommended: GoMono Nerd Font or FiraCode Nerd Font)"
    echo ""
    echo "  2. Install the font on Windows:"
    echo "     Extract zip → Right-click .ttf files → Install"
    echo ""
    echo "  3. Configure Windows Terminal:"
    echo "     Settings → Profiles → Defaults → Appearance → Font face"
    echo -e "     Select: ${CYAN}GoMono Nerd Font${NC} (or your chosen font)"
    echo ""
fi
