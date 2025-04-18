# Classical Language Dictionary CLI (`classdict`)

A fast and flexible command-line dictionary tool for looking up Latin and Ancient Greek words.

- **Latin**: Lewis & Short Latin Dictionary
- **Greek**: Liddell–Scott–Jones (LSJ) Greek Lexicon

## 🔍 Features

- **Multilingual support**: Lookup entries in Latin and Greek
- **Automatic language detection**: Based on input characters
- **SQLite-backed**: Fast indexed queries on structured dictionary data
- **Lemmatization support**: Optional integration with [Morpheus](https://github.com/perseids-tools/morpheus)
- **Fuzzy and normalized matching**: Diacritical- and case-insensitive search options
- **Exact match or suggestions**: Flexible word matching
- **Terminal-friendly**: Output to terminal or pager

## 📦 Installation

### Method 1: Using `Makefile`

```bash
make install-all          # Install both dictionaries system-wide
make install              # Install Latin dictionary system-wide
make install-greek        # Install Greek dictionary system-wide

make user-install-all     # Install both for current user only
make user-install         # Latin only for user
make user-install-greek   # Greek only for user
```

### Method 2: Using the Installation Script

```bash
./install.sh --all             # Install both dictionaries system-wide
./install.sh --user --all      # Install both for current user
./install.sh --latin           # Only Latin
./install.sh --greek           # Only Greek
./install.sh --morpheus        # Install Morpheus integration
```

## 🛠️ Usage

```bash
classdict [options] WORD
```

Extract entries from the Latin or Greek dictionaries.

### Options

```
Usage: classdict [options] WORD
Extract entries from Latin and Greek dictionaries

  -h, --help             Show this help message
  -f, --file FILE        Specify custom dictionary database
  -e, --exact            Require exact match (ignores fuzzy suggestions)
  -S, --suggest          Show similar word suggestions
  -L, --lemmatize        Normalize the input word using Morpheus
  -d, --direct           Print results directly to terminal (no pager)
  -v, --version          Show version information
  -l, --latin            Force Latin mode
  -g, --greek            Force Greek mode
  -m, --multiple [N]     Allow multiple matches and let user select (default: 5 matches)
```

### Examples

```bash
classdict amor               # Latin word lookup"
classdict λόγος              # Greek word lookup"
classdict --latin virtus     # Force Latin dictionary"
classdict --greek ἀρετή      # Force Greek dictionary"
classdict -e amo             # Exact match"
classdict -S amor            # Show suggestions if not found"
classidict -d amor     	     # Print directly to terminal
classdict -L amabam          # Lemmatize word first (amabam → amo)"
classdict -m 10 amo          # Show up to 10 matches and let user select
```

## 📁 Project Structure

```
.
├── bin/                   # Executable scripts
│   └── classdict          # Main CLI script
├── data/                  # Dictionary databases
│   ├── latin/
│   │   └── lewis-short.db
│   └── greek/
│       └── lsj.db
├── install.sh             # Installation script
├── Makefile               # Make-based installer
├── LICENSE                # BSD 3-Clause License
└── README.md              # This file
```

## 🙏 Credits

- **Lewis & Short** and **LSJ**: Perseus Digital Library, Tufts University
- **Morpheus**: [perseids-tools/morpheus](https://github.com/perseids-tools/morpheus)
- Thanks to The National Endowment for the Humanities for supporting public domain classics infrastructure

```
