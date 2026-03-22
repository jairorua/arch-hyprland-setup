#!/bin/bash

set -e

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_section() { echo -e "\n${BLUE}==>${NC} ${YELLOW}$1${NC}"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

# IMPORTANT: Change this to your actual dotfiles repo!
DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:jairorua/dotfiles.git}"
DOTFILES_DIR="$HOME/.dotfiles"

check_prerequisites() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Do not run as root. Run as your user."
        exit 1
    fi
    if ! command -v git &> /dev/null; then
        print_error "git required"
        exit 1
    fi
}

backup_conflicts() {
    print_section "Checking for conflicts"
    
    local git_cmd="/usr/bin/git --git-dir=$DOTFILES_DIR --work-tree=$HOME"
    
    # Attempt checkout, capture output regardless of exit code
    local checkout_output
    checkout_output=$($git_cmd checkout 2>&1) || true
    
    # Check if there were conflicts
    if echo "$checkout_output" | grep -q "would be overwritten by checkout"; then
        print_section "Backing up existing configs that conflict"
        
        # Parse the conflicting files
        echo "$checkout_output" | grep "^[[:space:]]" | while IFS= read -r file; do
            
            # Clean up whitespace
            file=$(echo "$file" | sed 's/^[[:space:]]*//')
            
            # Skip if empty or looks like an error message
            [ -z "$file" ] && continue
            [[ "$file" == *"error:"* ]] && continue
            
            if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
                mv "$HOME/$file" "$HOME/$file.backup.$(date +%s)"
                print_success "Backed up: $file"
            fi
        done
        
        # Retry checkout after backups
        $git_cmd checkout
    fi
    
    print_success "Checkout complete"
}

setup_dotfiles() {
    print_section "Setting up dotfiles"
    
    if [ -d "$DOTFILES_DIR" ]; then
        print_error "Dotfiles already exist at $DOTFILES_DIR"
        read -p "Update to latest? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            local git_cmd="/usr/bin/git --git-dir=$DOTFILES_DIR --work-tree=$HOME"
            $git_cmd fetch origin || true
            $git_cmd reset --hard origin/main 2>/dev/null || $git_cmd reset --hard origin/master
        fi
        return
    fi
    
    # Try SSH first, fallback to HTTPS
    print_section "Cloning $DOTFILES_REPO"
    
    if ! git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR" 2>/dev/null; then
        print_error "SSH clone failed. Trying HTTPS..."
        HTTPS_REPO=$(echo "$DOTFILES_REPO" | sed 's|git@github.com:|https://github.com/|')
        git clone --bare "$HTTPS_REPO" "$DOTFILES_DIR"
    fi
    
    print_success "Repository cloned"
}

configure_dotfiles() {
    print_section "Configuring dotfiles environment"
    
    local git_cmd="/usr/bin/git --git-dir=$DOTFILES_DIR --work-tree=$HOME"
    
    # Hide untracked files
    $git_cmd config --local status.showUntrackedFiles no
    
    print_success "Dotfiles configured"
}

setup_shell_function() {
    print_section "Configuring dotfiles function"

    local zshrc="$HOME/.zshrc"

    if [ -f "$zshrc" ]; then
        if ! grep -q "dotfilesconfig()" "$zshrc"; then
            print_error "dotfiles function not found in .zshrc"
            echo "Please ensure your repo includes the dotfilesconfig function."
        else
            print_success "dotfiles function already configured in .zshrc"
        fi
    else
        print_error ".zshrc not found"
    fi
}

install_plugins() {
    print_section "Installing plugins"
    
    # TPM (Tmux Plugin Manager)
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        print_success "TPM installed (open tmux, press prefix+I to install plugins)"
    fi
    
    # Neovim (headless plugin install)
    if command -v nvim &> /dev/null; then
        print_section "Syncing Neovim plugins"
        nvim --headless "+Lazy! sync" +qa 2>/dev/null || print_error "Neovim sync failed (will sync on first launch)"
    fi
}

main() {
    echo -e "${GREEN}Dotfiles Setup${NC}\n"
    check_prerequisites
    setup_dotfiles
    backup_conflicts
    configure_dotfiles
    setup_shell_function
    install_plugins
    
    echo -e "\n${GREEN}✓ Complete!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Reload shell: source ~/.zshrc (or open new terminal)"
    echo "  2. Test alias: dotfilesconfig status"
    echo "  3. Open tmux and press prefix+I to install tmux plugins"
}

main "$@"
