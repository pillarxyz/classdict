#!/bin/bash

# install.sh - Installation script for Latin/Greek Dictionary CLI
# Usage: ./install.sh [options]

# Default installation paths
INSTALL_DIR="/usr/local/bin"
DATA_DIR="/usr/local/share/classdict"
USER_INSTALL=false
FORCE_INSTALL=false
INSTALL_GREEK=false
INSTALL_LATIN=true  # Install Latin by default

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
    echo "Install the Latin & Greek Dictionary CLI tool"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -u, --user           Install for current user only (no sudo required)"
    echo "  -f, --force          Force installation (overwrite existing files)"
    echo "  -d, --dir DIRECTORY  Specify a different installation directory"
    echo "  -g, --greek          Install Greek dictionary (LSJ)"
    echo "  -l, --latin          Install Latin dictionary (Lewis & Short, default)"
    echo "  -a, --all            Install both Latin and Greek dictionaries"
    echo ""
    echo "Example: $0 --user      # Install Latin dictionary for current user"
    echo "         $0 --all       # Install both dictionaries system-wide"
    echo "         $0 --greek     # Install only Greek dictionary"
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
        -g|--greek)
            INSTALL_GREEK=true
            INSTALL_LATIN=false
            shift
            ;;
        -l|--latin)
            INSTALL_LATIN=true
            INSTALL_GREEK=false
            shift
            ;;
        -a|--all)
            INSTALL_LATIN=true
            INSTALL_GREEK=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Check source files exist
if [ -f "$SCRIPT_DIR/bin/classdict" ]; then
    SCRIPT_PATH="$SCRIPT_DIR/bin/classdict"
elif [ -f "$SCRIPT_DIR/bin/lslatdict" ]; then
    SCRIPT_PATH="$SCRIPT_DIR/bin/lslatdict"
    echo -e "${YELLOW}Found old script name (lslatdict). Will install as classdict.${NC}"
elif [ -f "$SCRIPT_DIR/classdict" ]; then
    SCRIPT_PATH="$SCRIPT_DIR/classdict"
elif [ -f "$SCRIPT_DIR/lslatdict" ]; then
    SCRIPT_PATH="$SCRIPT_DIR/lslatdict"
    echo -e "${YELLOW}Found old script name (lslatdict). Will install as classdict.${NC}"
else
    echo -e "${RED}Error: Cannot find classdict script in bin/ directory or current directory${NC}"
    exit 1
fi

# Check Latin dictionary files if needed
if [ "$INSTALL_LATIN" = true ]; then
    if [ -f "$SCRIPT_DIR/data/latin/lewis-short.txt" ]; then
        LAT_DICT_PATH="$SCRIPT_DIR/data/latin/lewis-short.txt"
    elif [ -f "$SCRIPT_DIR/data/lewis-short.txt" ]; then
        LAT_DICT_PATH="$SCRIPT_DIR/data/lewis-short.txt"
    elif [ -f "$SCRIPT_DIR/lewis-short.txt" ]; then
        LAT_DICT_PATH="$SCRIPT_DIR/lewis-short.txt"
    else
        echo -e "${RED}Error: Cannot find Latin dictionary files${NC}"
        exit 1
    fi
fi

# Check Greek dictionary files if needed
if [ "$INSTALL_GREEK" = true ]; then
    if [ -f "$SCRIPT_DIR/data/greek/lsj.txt" ]; then
        GRK_DICT_PATH="$SCRIPT_DIR/data/greek/lsj.txt"
    elif [ -f "$SCRIPT_DIR/data/lsj.txt" ]; then
        GRK_DICT_PATH="$SCRIPT_DIR/data/lsj.txt"
    elif [ -f "$SCRIPT_DIR/lsj.txt" ]; then
        GRK_DICT_PATH="$SCRIPT_DIR/lsj.txt"
    else
        echo -e "${YELLOW}Warning: Greek dictionary files not found${NC}"
        echo -e "${YELLOW}Greek dictionary installation will be skipped${NC}"
        INSTALL_GREEK=false
    fi
fi

# Ensure at least one dictionary will be installed
if [ "$INSTALL_LATIN" = false ] && [ "$INSTALL_GREEK" = false ]; then
    echo -e "${RED}Error: No dictionaries selected for installation${NC}"
    echo "Please specify at least one dictionary to install:"
    echo "  --latin    Install Latin dictionary"
    echo "  --greek    Install Greek dictionary"
    echo "  --all      Install both dictionaries"
    exit 1
fi

# Set up installation paths based on user/system installation
if [ "$USER_INSTALL" = true ]; then
    INSTALL_DIR="$HOME/bin"
    DATA_DIR="$HOME/.local/share/classdict"
    echo -e "${YELLOW}Performing user installation to:${NC}"
else
    echo -e "${YELLOW}Performing system-wide installation to:${NC}"
fi

echo -e "  ${GREEN}Executable:${NC} $INSTALL_DIR/classdict"
echo -e "  ${GREEN}Dictionary:${NC} $DATA_DIR/"

if [ "$INSTALL_LATIN" = true ]; then
    echo -e "  ${GREEN}Installing:${NC} Latin dictionary (Lewis & Short)"
fi

if [ "$INSTALL_GREEK" = true ]; then
    echo -e "  ${GREEN}Installing:${NC} Greek dictionary (Liddell-Scott-Jones)"
fi

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

    # Create data directories
    if [ "$INSTALL_LATIN" = true ]; then
        if [ ! -d "$DATA_DIR/latin" ]; then
            $sudo_cmd mkdir -p "$DATA_DIR/latin"
        fi
    fi

    if [ "$INSTALL_GREEK" = true ]; then
        if [ ! -d "$DATA_DIR/greek" ]; then
            $sudo_cmd mkdir -p "$DATA_DIR/greek"
        fi
    fi

    # Check if creation was successful
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "${RED}Failed to create bin directory.${NC}"
        exit 1
    fi

    if [ "$INSTALL_LATIN" = true ] && [ ! -d "$DATA_DIR/latin" ]; then
        echo -e "${RED}Failed to create Latin dictionary directory.${NC}"
        exit 1
    fi

    if [ "$INSTALL_GREEK" = true ] && [ ! -d "$DATA_DIR/greek" ]; then
        echo -e "${RED}Failed to create Greek dictionary directory.${NC}"
        exit 1
    fi
}

# Check if the script already exists and handle accordingly
check_existing() {
    if [ -f "$INSTALL_DIR/classdict" ] && [ "$FORCE_INSTALL" = false ]; then
        echo -e "${YELLOW}Dictionary tool already exists at $INSTALL_DIR/classdict${NC}"
        read -p "Do you want to overwrite it? (y/n): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    fi

    if [ "$INSTALL_LATIN" = true ] && [ -f "$DATA_DIR/latin/lewis-short.txt" ] && [ "$FORCE_INSTALL" = false ]; then
        echo -e "${YELLOW}Latin dictionary files already exist in $DATA_DIR/latin${NC}"
        read -p "Do you want to overwrite them? (y/n): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Will preserve existing Latin dictionary files."
            PRESERVE_LAT_DICT=true
        else
            PRESERVE_LAT_DICT=false
        fi
    else
        PRESERVE_LAT_DICT=false
    fi

    if [ "$INSTALL_GREEK" = true ] && [ -f "$DATA_DIR/greek/lsj.txt" ] && [ "$FORCE_INSTALL" = false ]; then
        echo -e "${YELLOW}Greek dictionary files already exist in $DATA_DIR/greek${NC}"
        read -p "Do you want to overwrite them? (y/n): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Will preserve existing Greek dictionary files."
            PRESERVE_GRK_DICT=true
        else
            PRESERVE_GRK_DICT=false
        fi
    else
        PRESERVE_GRK_DICT=false
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
    cp "$SCRIPT_PATH" "$SCRIPT_DIR/classdict.tmp"

    # Update the dictionary paths
    if [ "$INSTALL_LATIN" = true ]; then
        sed -i "s|LAT_DICT_FILE=\"data/latin/lewis-short.txt\"|LAT_DICT_FILE=\"$DATA_DIR/latin/lewis-short.txt\"|g" "$SCRIPT_DIR/classdict.tmp"
    fi

    if [ "$INSTALL_GREEK" = true ]; then
        sed -i "s|GRK_DICT_FILE=\"data/greek/lsj.txt\"|GRK_DICT_FILE=\"$DATA_DIR/greek/lsj.txt\"|g" "$SCRIPT_DIR/classdict.tmp"
    fi

    # Install the script
    echo "Installing script..."
    $sudo_cmd cp "$SCRIPT_DIR/classdict.tmp" "$INSTALL_DIR/classdict"
    $sudo_cmd chmod +x "$INSTALL_DIR/classdict"
    rm "$SCRIPT_DIR/classdict.tmp"

    # Install the Latin dictionary files
    if [ "$INSTALL_LATIN" = true ] && [ "$PRESERVE_LAT_DICT" = false ]; then
        echo "Installing Latin dictionary files..."
        $sudo_cmd cp "$LAT_DICT_PATH" "$DATA_DIR/latin/"
    fi

    # Install the Greek dictionary files
    if [ "$INSTALL_GREEK" = true ] && [ "$PRESERVE_GRK_DICT" = false ]; then
        echo "Installing Greek dictionary files..."
        $sudo_cmd cp "$GRK_DICT_PATH" "$DATA_DIR/greek/"
    fi

    # Verify installation
    if [ ! -f "$INSTALL_DIR/classdict" ]; then
        echo -e "${RED}Failed to install script.${NC}"
        exit 1
    fi

    if [ "$INSTALL_LATIN" = true ] && [ "$PRESERVE_LAT_DICT" = false ] && [ ! -f "$DATA_DIR/latin/lewis-short.txt" ]; then
        echo -e "${RED}Failed to install Latin dictionary files.${NC}"
        exit 1
    fi

    if [ "$INSTALL_GREEK" = true ] && [ "$PRESERVE_GRK_DICT" = false ] && [ ! -f "$DATA_DIR/greek/lsj.txt" ]; then
        echo -e "${RED}Failed to install Greek dictionary files.${NC}"
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
echo "You can now use the dictionary tool by typing 'classdict' followed by a Latin or Greek word."
echo "Examples:"
echo "  classdict amor          # Latin word"
if [ "$INSTALL_GREEK" = true ]; then
    echo "  classdict λόγος        # Greek word"
    echo "  classdict --greek ἀρετή  # Force Greek dictionary"
fi
echo "  classdict --latin virtus  # Force Latin dictionary"
