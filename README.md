# *A Latin Dictionary* (edd. Lewis & Short) with Command Line Interface

## What?

This repository contains:

1. Two plain text versions of *A Latin Dictionary* (edd. Charlton T. Lewis and Charles Short):
   - `lewis-short.txt`: Standard version with straight quotes
   - `lewis-short-smart-quotes.txt`: Version with curly quotes

2. A command-line tool (`lslatdict`) for quickly looking up Latin words in the dictionary

3. Easy installation options via `Makefile` or installation script

These files are based on the XML version that [the Perseus Digital Library](http://www.perseus.tufts.edu/hopper/) has [made available under a Creative-Commons license](https://github.com/PerseusDL/lexica/tree/master/CTS_XML_TEI/perseus/pdllex/lat/ls).

## Why?

The Lewis & Short Latin Dictionary is a valuable resource for Latin scholars, students, and enthusiasts. While it's available online in various formats, this project makes it accessible as plain text with a convenient command-line interface. The CLI tool makes it easy to quickly look up words without opening a web browser or large application.

## Installation

### Method 1: Using Make (Recommended)

```bash
# Install system-wide (requires sudo)
make install

# OR install for current user only (no sudo required)
make user-install

# To uninstall
make uninstall      # System-wide
make user-uninstall # User installation
```

### Method 2: Using the Installation Script

```bash
# System-wide installation (requires sudo)
./install.sh

# User-only installation (no sudo required)
./install.sh --user

# For more options
./install.sh --help
```

### Method 3: Manual Installation

```bash
# Make the script executable
chmod +x bin/lslatdict

# Copy the script to your bin directory
cp bin/lslatdict ~/bin/
# or system-wide
sudo cp bin/lslatdict /usr/local/bin/

# Create a directory for the dictionary files
mkdir -p ~/.local/share/lslatdict
# or system-wide
sudo mkdir -p /usr/local/share/lslatdict

# Copy the dictionary files
cp data/lewis-short*.txt ~/.local/share/lslatdict/
# or system-wide
sudo cp data/lewis-short*.txt /usr/local/share/lslatdict/
```

## Usage

```
Usage: lslatdict [options] LATIN_WORD
Extract entries from Lewis & Short Latin Dictionary

Options:
  -h, --help             Show this help message
  -f, --file FILE        Specify a different dictionary file path
  -s, --smart            Use the smart-quotes version of the dictionary
  -c, --context LINES    Show LINES of context before and after the match
  -e, --exact            Require exact match (with diacritical flexibility)
  -S, --suggest          Show suggestions for similar words when no match is found
  -d, --direct           Print directly to terminal (no external viewer)
  -v, --version          Display version information
```

### Examples

```bash
# Basic lookup
lslatdict amor

# Use smart quotes version
lslatdict --smart virtus

# Show 5 lines of context around the entry
lslatdict -c 5 virtus

# Exact match (still handles diacritical marks)
lslatdict -e amo

# Get suggestions for similar words
lslatdict -S faci

# Print directly to terminal (no pager)
lslatdict -d amor
```

## Features

- **Fast lookup**: Quickly find dictionary entries by headword
- **Diacritical marks support**: Find entries regardless of macrons, breves, etc.
- **Smart quotes option**: Choose between straight quotes and curly quotes
- **Context view**: See surrounding entries for better browsing
- **Suggestions**: Get related entries when no exact match is found
- **Flexible matching**: Find words even with alternative spellings or forms

## Project Structure

```
.
├── bin/                    # Executable scripts
│   └── lslatdict           # Main dictionary lookup tool
├── data/                   # Dictionary data files
│   ├── lewis-short.txt
│   └── lewis-short-smart-quotes.txt
├── scripts/                # Utility scripts
│   ├── parse-ls-xml.py     # XML to text conversion script
│   └── sed_commands.txt    # Commands used in text conversion
├── install.sh              # Installation script
├── LICENSE                 # BSD 3-Clause License
├── Makefile                # For easy installation management
└── README.md               # This file
```

## About the Dictionary Files

The two dictionary files are identical except for quote formatting:

- `lewis-short.txt`: Uses straight quotes (faster processing)
- `lewis-short-smart-quotes.txt`: Uses curly quotes (better typography)

Both files contain Unicode Greek characters rather than Beta code, making them more readable and useful for scholars.

## Technical Details

The original project used [a tool provided by PerseusDL](https://github.com/PerseusDL/tei-conversion-tools) to transform the beta code in the XML file into unicode Greek and a set of `sed` commands to transform all of the remaining character entities into unicode. The content was then extracted using a Python script.

The CLI tool (`lslatdict`) is a Bash script that:

1. Searches for Latin words in the dictionary text files
2. Handles Latin diacritical marks intelligently
3. Extracts complete entries or context windows
4. Provides suggestions for related entries

## Credits

- Original dictionary text provided by Perseus Digital Library, with funding from The National Endowment for the Humanities
- Original plain text conversion by [Joseph Holsten](https://github.com/josephholsten)
- CLI tool developed as an extension to the original project

## License

- The Lewis and Short text files are licensed under [the CC BY-SA 3.0 license](https://creativecommons.org/licenses/by-sa/3.0/us/)
- The Python script, `sed` commands, and CLI tool are licensed under [the BSD 3-Clause license](https://opensource.org/licenses/BSD-3-Clause)
