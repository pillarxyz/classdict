# Classical Language Dictionary CLI

A command-line interface for classical language dictionaries:

- **Latin**: Lewis & Short Latin Dictionary
- **Greek**: Liddell-Scott-Jones Greek Lexicon

## What?

This repository contains:

1. Plain text versions of classical language dictionaries:
   - **Latin**: Lewis & Short Latin Dictionary
     - `lewis-short.txt`
   - **Greek**: Liddell-Scott-Jones Greek Lexicon
     - `lsj.txt`

2. A command-line tool (`classidict`) for quickly looking up words in these dictionaries

3. Easy installation options via `Makefile` or installation script

The dictionary files are based on the XML versions from [the Perseus Digital Library](http://www.perseus.tufts.edu/hopper/) made available under a Creative-Commons license.

## Why?

Classical language dictionaries are valuable resources for scholars, students, and enthusiasts. While they're available online in various formats, this project makes them accessible as plain text with a convenient command-line interface. The CLI tool makes it easy to quickly look up words without opening a web browser or large application.

## Installation

### Method 1: Using Make (Recommended)

```bash
# Install Latin dictionary system-wide (requires sudo)
make install

# Install Greek dictionary system-wide (requires sudo)
make install-greek

# Install both dictionaries system-wide (requires sudo)
make install-all

# Install Latin dictionary for current user only (no sudo required)
make user-install

# Install Greek dictionary for current user only (no sudo required)
make user-install-greek

# Install both dictionaries for current user only (no sudo required)
make user-install-all

# To uninstall
make uninstall      # System-wide
make user-uninstall # User installation
```

### Method 2: Using the Installation Script

```bash
# System-wide installation of Latin dictionary (requires sudo)
./install.sh --latin

# System-wide installation of Greek dictionary (requires sudo)
./install.sh --greek

# System-wide installation of both dictionaries (requires sudo)
./install.sh --all

# User-only installation of Latin dictionary (no sudo required)
./install.sh --user --latin

# User-only installation of Greek dictionary (no sudo required)
./install.sh --user --greek

# User-only installation of both dictionaries (no sudo required)
./install.sh --user --all

# For more options
./install.sh --help
```

## Usage

```
Usage: classidict [options] WORD
Extract entries from Latin (Lewis & Short) and Greek (LSJ) dictionaries

Options:
  -h, --help             Show this help message
  -f, --file FILE        Specify a different dictionary file path
  -c, --context LINES    Show LINES of context before and after the match
  -e, --exact            Require exact match (with diacritical flexibility)
  -S, --suggest          Show suggestions for similar words when no match is found
  -d, --direct           Print directly to terminal (no external viewer)
  -v, --version          Display version information
  -l, --latin            Force Latin dictionary mode
  -g, --greek            Force Greek dictionary mode
```

### Examples

```bash
# Basic lookup (auto-detects language)
classidict amor        # Latin word
classidict λόγος      # Greek word

# Force specific dictionary
classidict --latin virtus
classidict --greek ἀρετή

# Show 5 lines of context around the entry
classidict -c 5 virtus

# Exact match (still handles diacritical marks)
classidict -e amo

# Get suggestions for similar words
classidict -S faci

# Print directly to terminal (no pager)
classidict -d amor
```

## Features

- **Multilingual support**: Look up words in both Latin and Greek dictionaries
- **Automatic language detection**: Detects whether to use Latin or Greek dictionary based on characters used
- **Fast lookup**: Quickly find dictionary entries by headword
- **Diacritical marks support**: Find entries regardless of diacritics
- **Smart quotes option**: Choose between straight quotes and curly quotes
- **Context view**: See surrounding entries for better browsing
- **Suggestions**: Get related entries when no exact match is found
- **Flexible matching**: Find words even with alternative spellings or forms

## Project Structure

```
.
├── bin/                    # Executable scripts
│   └── classidict              # Main dictionary lookup tool
├── data/                   # Dictionary data files
│   ├── latin/              # Latin dictionary files
│   │   ├── lewis-short.txt
│   └── greek/              # Greek dictionary files
│       ├── lsj.txt
├── scripts/                # Utility scripts
│   ├── parse-ls-xml.py     # XML to text conversion script for Latin
│   └── sed_commands.txt    # Commands used in text conversion
├── install.sh              # Installation script
├── LICENSE                 # BSD 3-Clause License
├── Makefile                # For easy installation management
└── README.md               # This file
```

## Adding the LSJ Greek Dictionary

To add the LSJ Greek Dictionary to this project:

1. Obtain the Liddell-Scott-Jones plain text files
   - These may be available from the Perseus Digital Library or other academic sources
   - You may need to convert from XML or other formats if plain text isn't directly available

2. Place the files in the correct location:
   ```
   data/greek/lsj.txt
   ```

3. Install using the updated installation options:
   ```bash
   make install-all       # For system-wide installation
   # OR
   make user-install-all  # For user-only installation
   ```

## Technical Details

The dictionaries were originally converted from XML versions using conversion tools. The CLI tool (`classidict`) is a Bash script that:

1. Detects whether the query is Latin or Greek (or allows manual specification)
2. Searches for words in the appropriate dictionary files
3. Handles diacritical marks intelligently for both languages
4. Extracts complete entries or context windows
5. Provides suggestions for related entries

## Credits

- Original dictionary texts provided by Perseus Digital Library, with funding from The National Endowment for the Humanities
- Original Latin plain text conversion by [Joseph Holsten](https://github.com/josephholsten)
- CLI tool and Greek integration developed as an extension to the original project

## License

- The dictionary text files are licensed under [the CC BY-SA 3.0 license](https://creativecommons.org/licenses/by-sa/3.0/us/)
- The Python script, `sed` commands, and CLI tool are licensed under [the BSD 3-Clause license](https://opensource.org/licenses/BSD-3-Clause)
