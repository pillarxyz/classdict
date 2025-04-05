# Classical Language Dictionary CLI

A command-line interface for looking up words in classical Latin and Greek dictionaries:

- **Latin**: Lewis & Short Latin Dictionary
- **Greek**: Liddell-Scott-Jones Greek Lexicon

## Features

- **Multilingual support**: Lookup words in both Latin and Greek dictionaries
- **Automatic language detection**: Based on word characters
- **Exact match and suggestions**: Search for exact matches or get similar word suggestions
- **Context view**: See surrounding entries
- **Diacritical flexibility**: Handle diacritical marks properly
- **Terminal-friendly**: Option to print directly to terminal

## Installation

### Method 1: Using `Makefile`

```bash
make install-all   # Install both dictionaries system-wide
make install-greek # Install Greek dictionary
make install       # Install Latin dictionary

make user-install-all   # Install for current user
make user-install-greek  # Install Greek for current user
make user-install        # Install Latin for current user
```

### Method 2: Using the Installation Script

```bash
./install.sh --all       # System-wide installation of both dictionaries
./install.sh --user --all # User-only installation of both dictionaries
```

## Usage

```bash
Usage: classdict [options] WORD
Extract entries from Latin and Greek dictionaries

  -h, --help             Show this help message
  -f, --file FILE        Specify a different dictionary file path
  -c, --context LINES    Show LINES of context around the match
  -e, --exact            Require exact match (with diacritical flexibility)
  -S, --suggest          Show suggestions for similar words
  -L, --lemmatize        Replace the word with its lemma
  -d, --direct           Print directly to terminal (no pager)
  -v, --version          Show version info
  -l, --latin            Force Latin dictionary mode
  -g, --greek            Force Greek dictionary mode
```

### Examples

```bash
classidict amor        # Lookup Latin word
classidict λόγος       # Lookup Greek word
classidict --latin virtus
classidict --greek ἀρετή
classidict -c 5 virtus # Show 5 lines of context
classidict -e amo      # Exact match
classidict -S faci     # Get suggestions for similar words
classidict -d amor     # Print directly to terminal
```

## Project Structure

```
.
├── bin/                   # Executable scripts
│   └── classidict         # Main lookup tool
├── data/                  # Dictionary files
│   ├── latin/             # Latin dictionary files
│   │   └── lewis-short.txt
│   └── greek/             # Greek dictionary files
│       └── lsj.txt
├── install.sh             # Installation script
├── LICENSE                # BSD 3-Clause License
├── Makefile               # Installation management
└── README.md              # This file
```

## Adding the LSJ Greek Dictionary

Currently the Ancient Greek LSJ dictionary is not well-parsed as I would have like if you want to add the LSJ Greek Dictionary by yourself:

1. Get the dictionary files from [PerseusDL](https://github.com/PerseusDL).
2. Parse the XML files to plain text files.
3. Place them in `data/greek/lsj.txt`.
4. Install using:

```bash
make install-all       # For system-wide installation
make user-install-all  # For user-only installation
```

## Credits

- Original dictionary texts from Perseus Digital Library, funded by The National Endowment for the Humanities
- [Morpheus'](https://github.com/perseids-tools/morpheus) morphological parsing tool
