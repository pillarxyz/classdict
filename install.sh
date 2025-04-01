#!/bin/bash

# install.sh - Installation script for Lewis & Short Latin Dictionary CLI
# Usage: ./install.sh [options]

# Default installation paths
INSTALL_DIR="/usr/local/bin"
DATA_DIR="/usr/local/share/lslatdict"
USER_INSTALL=false
FORCE_INSTALL=false

# Script directory - to find files regardless of where script is run from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo "Install the Lewis & Short Latin Dictionary CLI tool"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -u, --user           Install for current user only (no sudo required)"
    echo "  -f, --force          Force installation (overwrite existing files)"
    echo "  -d, --dir DIRECTORY  Specify a different installation directory"
    echo ""
    echo "Example: $0 --user      # Install in ~/bin and ~/.local/share"
    echo "         $0 --force     # Force system-wide installation"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -u|--user)
            USER_INSTALL=true
            shift
            ;;
        -f|--force)
            FORCE_INSTALL=true
            shift
            ;;
        -d|--dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Check source files exist
if [ -f "$SCRIPT_DIR/bin/lslatdict" ]; then
    SCRIPT_PATH="$SCRIPT_DIR/bin/lslatdict"
elif [ -f "$SCRIPT_DIR/lslatdict" ]; then
    SCRIPT_PATH="$SCRIPT_DIR/lslatdict"
else
    echo -e "${RED}Error: Cannot find lslatdict script in bin/ directory or current directory${NC}"
    exit 1
fi

# Check dictionary files
if [ -f "$SCRIPT_DIR/data/lewis-short.txt" ]; then
    DICT_PATH="$SCRIPT_DIR/data/lewis-short.txt"
    SMART_DICT_PATH="$SCRIPT_DIR/data/lewis-short-smart-quotes.txt"
elif [ -f "$SCRIPT_DIR/lewis-short.txt" ]; then
    DICT_PATH="$SCRIPT_DIR/lewis-short.txt"
    SMART_DICT_PATH="$SCRIPT_DIR/lewis-short-smart-quotes.txt"
else
    echo -e "${RED}Error: Cannot find dictionary files in data/ directory or current directory${NC}"
    exit 1
fi

# Set up installation paths based on user/system installation
if [ "$USER_INSTALL" = true ]; then
    INSTALL_DIR="$HOME/bin"
    DATA_DIR="$HOME/.local/share/lslatdict"
    echo -e "${YELLOW}Performing user installation to:${NC}"
else
    echo -e "${YELLOW}Performing system-wide installation to:${NC}"
fi

echo -e "  ${GREEN}Executable:${NC} $INSTALL_DIR/lslatdict"
echo -e "  ${GREEN}Dictionary:${NC} $DATA_DIR/"

# Create necessary directories
create_dirs() {
    local sudo_cmd=""
    if [ "$USER_INSTALL" = false ]; then
        sudo_cmd="sudo"
    fi

    echo "Creating directories..."

    # Create bin directory if needed
    if [ ! -d "$INSTALL_DIR" ]; then
        $sudo_cmd mkdir -p "$INSTALL_DIR"
    fi

    # Create data directory
    if [ ! -d "$DATA_DIR" ]; then
        $sudo_cmd mkdir -p "$DATA_DIR"
    fi

    # Check if creation was successful
    if [ ! -d "$INSTALL_DIR" ] || [ ! -d "$DATA_DIR" ]; then
        echo -e "${RED}Failed to create necessary directories.${NC}"
        exit 1
    fi
}

# Check if the script already exists and handle accordingly
check_existing() {
    if [ -f "$INSTALL_DIR/lslatdict" ] && [ "$FORCE_INSTALL" = false ]; then
        echo -e "${YELLOW}Dictionary tool already exists at $INSTALL_DIR/lslatdict${NC}"
        read -p "Do you want to overwrite it? (y/n): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    fi

    if [ -f "$DATA_DIR/lewis-short.txt" ] && [ "$FORCE_INSTALL" = false ]; then
        echo -e "${YELLOW}Dictionary files already exist in $DATA_DIR${NC}"
        read -p "Do you want to overwrite them? (y/n): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Will preserve existing dictionary files."
            PRESERVE_DICT=true
        else
            PRESERVE_DICT=false
        fi
    else
        PRESERVE_DICT=false
    fi
}

# Install the files
install_files() {
    local sudo_cmd=""
    if [ "$USER_INSTALL" = false ]; then
        sudo_cmd="sudo"
    fi

    echo "Installing files..."

    # Modify script to point to the correct dictionary location
    echo "Configuring dictionary path in script..."
    # Create a temporary copy of the script
    cp "$SCRIPT_PATH" "$SCRIPT_DIR/lslatdict.tmp"

    # Update the dictionary paths
    sed -i "s|DICTIONARY_FILE=\"lewis-short.txt\"|DICTIONARY_FILE=\"$DATA_DIR/lewis-short.txt\"|g" "$SCRIPT_DIR/lslatdict.tmp"
    sed -i "s|SMART_QUOTES_FILE=\"lewis-short-smart-quotes.txt\"|SMART_QUOTES_FILE=\"$DATA_DIR/lewis-short-smart-quotes.txt\"|g" "$SCRIPT_DIR/lslatdict.tmp"

    # Install the script
    echo "Installing script..."
    $sudo_cmd cp "$SCRIPT_DIR/lslatdict.tmp" "$INSTALL_DIR/lslatdict"
    $sudo_cmd chmod +x "$INSTALL_DIR/lslatdict"
    rm "$SCRIPT_DIR/lslatdict.tmp"

    # Install the dictionary files
    if [ "$PRESERVE_DICT" = false ]; then
        echo "Installing dictionary files..."
        $sudo_cmd cp "$DICT_PATH" "$DATA_DIR/"
        if [ -f "$SMART_DICT_PATH" ]; then
            $sudo_cmd cp "$SMART_DICT_PATH" "$DATA_DIR/"
        else
            echo -e "${YELLOW}Warning: Smart quotes dictionary file not found. Skipping.${NC}"
        fi
    fi

    # Verify installation
    if [ ! -f "$INSTALL_DIR/lslatdict" ]; then
        echo -e "${RED}Failed to install script.${NC}"
        exit 1
    fi

    if [ "$PRESERVE_DICT" = false ] && [ ! -f "$DATA_DIR/lewis-short.txt" ]; then
        echo -e "${RED}Failed to install dictionary files.${NC}"
        exit 1
    fi
}

# Update PATH if necessary for user installation
update_path() {
    if [ "$USER_INSTALL" = true ] && [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        echo "Updating PATH in shell profile..."

        # Determine which shell profile to update
        if [ -f "$HOME/.bashrc" ]; then
            profile="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            profile="$HOME/.bash_profile"
        elif [ -f "$HOME/.zshrc" ]; then
            profile="$HOME/.zshrc"
        else
            echo -e "${YELLOW}Could not find shell profile. You may need to manually add $HOME/bin to your PATH.${NC}"
            return
        fi

        echo 'export PATH="$HOME/bin:$PATH"' >> "$profile"
        echo -e "${YELLOW}Added $HOME/bin to PATH in $profile${NC}"
        echo -e "${YELLOW}Please restart your terminal or run 'source $profile' to update your PATH.${NC}"
    fi
}

# Run the installation process
create_dirs
check_existing
install_files
update_path

echo -e "${GREEN}Installation complete!${NC}"
echo "You can now use the dictionary tool by typing 'lslatdict' followed by a Latin word."
echo "Example: lslatdict amor"
