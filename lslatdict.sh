#!/bin/bash

# lslatdict.sh - Tool to extract entries from Lewis & Short Latin Dictionary
# Usage: ./lslatdict.sh [options] LATIN_WORD

# Copyright (c) 2025, Ayman Lafaz
# All rights reserved.
# Licensed under the BSD 3-Clause License
# See LICENSE file for details


# Configuration - change this to the path of your dictionary file
DICTIONARY_FILE="lewis-short.txt"
# DICTIONARY_FILE="lewis-short-smart-quotes.txt" # Uncomment to use the version with smart quotes

# Function to display usage information
show_usage() {
    echo "Usage: $0 [options] LATIN_WORD"
    echo "Extract entries from Lewis & Short Latin Dictionary"
    echo ""
    echo "Options:"
    echo "  -h, --help             Show this help message"
    echo "  -f, --file FILE        Specify a different dictionary file path"
    echo "  -s, --smart            Use the smart-quotes version of the dictionary"
    echo "  -c, --context LINES    Show LINES of context before and after the match"
    echo "  -e, --exact            Require exact match (with diacritical flexibility)"
    echo "  -S, --suggest          Show suggestions for similar words when no match is found"
    echo ""
    echo "Example: $0 zythum"
    echo "         $0 --smart amor"
    echo "         $0 -c 5 virtus     # Show 5 lines of context"
    echo "         $0 -e amo          # Exact match (allows for diacritics)"
}

# Parse command-line arguments
USE_SMART_QUOTES=false
CONTEXT_LINES=0
EXACT_MATCH=false
SUGGEST=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -f|--file)
            DICTIONARY_FILE="$2"
            shift 2
            ;;
        -s|--smart)
            USE_SMART_QUOTES=true
            DICTIONARY_FILE="lewis-short-smart-quotes.txt"
            shift
            ;;
        -c|--context)
            CONTEXT_LINES="$2"
            shift 2
            ;;
        -e|--exact)
            EXACT_MATCH=true
            shift
            ;;
        -S|--suggest)
            SUGGEST=true
            shift
            ;;
        *)
            SEARCH_WORD="$1"
            shift
            ;;
    esac
done

# Validate input
if [ -z "$SEARCH_WORD" ]; then
    echo "Error: No Latin word specified!"
    show_usage
    exit 1
fi

if [ ! -f "$DICTIONARY_FILE" ]; then
    echo "Error: Dictionary file '$DICTIONARY_FILE' not found!"
    echo "Make sure you're running this script from the directory containing the dictionary file,"
    echo "or specify the correct path with the -f option."
    exit 1
fi

echo "Searching for '$SEARCH_WORD' in Lewis & Short Latin Dictionary..."
echo "-------------------------------------------------------------"

# Create a diacritical-flexible pattern for Latin characters
create_diacritic_pattern() {
    local input="$1"
    local pattern=""

    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            [aA]) pattern+="[aAāăäÄ]" ;;
            [eE]) pattern+="[eEēĕëË]" ;;
            [iI]) pattern+="[iIīĭïÏ]" ;;
            [oO]) pattern+="[oOōŏöÖ]" ;;
            [uU]) pattern+="[uUūŭüÜ]" ;;
            [yY]) pattern+="[yYȳÿŸ]" ;;
            *) pattern+="$char" ;;
        esac
    done

    echo "$pattern"
}

# Handle exact match with diacritical flexibility
if [ "$EXACT_MATCH" = true ]; then
    # Create pattern with diacritical flexibility
    relaxed_pattern=$(create_diacritic_pattern "$SEARCH_WORD")

    # Look for the exact word with diacritical flexibility at line start
    pattern="^$relaxed_pattern[[:punct:][:space:]]"
    line_number=$(grep -n "$pattern" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)

    # If not found, try case-insensitive
    if [ -z "$line_number" ]; then
        line_number=$(grep -in "$pattern" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)
    fi
else
    # Standard search with progressive relaxation
    pattern="^$SEARCH_WORD[[:punct:][:space:]]"
    line_number=$(grep -n "$pattern" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)

    # If not found, try more flexible approaches
    if [ -z "$line_number" ]; then
        # Try looking for the word as part of a verb entry (like "ămo, āvi, ātum")
        # This helps with entries that have diacritical marks at the beginning
        line_number=$(grep -n "^[ăāĕēĭīŏōŭū]$SEARCH_WORD[,[:space:]]" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)

        # Try ignoring case for more flexible matching
        if [ -z "$line_number" ]; then
            line_number=$(grep -in "^$SEARCH_WORD[[:punct:][:space:]]" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)
        fi

        # Try a more relaxed search that accounts for diacritical marks
        if [ -z "$line_number" ]; then
            relaxed_pattern=$(create_diacritic_pattern "$SEARCH_WORD")
            line_number=$(grep -n "^$relaxed_pattern[[:punct:][:space:]]" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)

            # If still not found, try another approach - sometimes entries have hyphens, brackets, etc.
            if [ -z "$line_number" ]; then
                # Remove leading/trailing dashes or brackets to catch compound forms
                relaxed_pattern=$(echo "$relaxed_pattern" | sed 's/^\[\^-\]//; s/\[\^-\]$//')
                line_number=$(grep -n "^[^-]*$relaxed_pattern[^-]*[[:punct:][:space:]]" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)
            fi
        fi

        # If still not found, try removing the last character (for declined/conjugated forms)
        if [ -z "$line_number" ] && [ ${#SEARCH_WORD} -gt 2 ]; then
            stem="${SEARCH_WORD%?}"
            stem_pattern=$(create_diacritic_pattern "$stem")
            line_number=$(grep -n "^$stem_pattern[[:alpha:]]*[,[:space:]]" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)
        fi
    fi
fi

# If we still haven't found the word, try to provide suggestions if enabled
if [ -z "$line_number" ]; then
    echo "No entry found for '$SEARCH_WORD'."
    echo "Try checking the spelling or searching for a different form of the word."

    if [ "$SUGGEST" = true ]; then
        echo ""
        echo "Possible related entries:"
        relaxed_pattern=$(create_diacritic_pattern "$SEARCH_WORD")
        grep -i "^$relaxed_pattern" "$DICTIONARY_FILE" | head -5

        # If nothing found with prefix, try substring match
        if [ -z "$(grep -i "^$relaxed_pattern" "$DICTIONARY_FILE" | head -1)" ]; then
            echo ""
            echo "Or perhaps one of these entries contains your word:"
            grep -i "$SEARCH_WORD" "$DICTIONARY_FILE" | head -5
        fi
    fi

    exit 0
fi

# If we're using context mode, display specified number of lines around the match
if [ "$CONTEXT_LINES" -gt 0 ]; then
    # Calculate the start line, ensuring it's not less than 1
    start_line=$((line_number - CONTEXT_LINES))
    [ "$start_line" -lt 1 ] && start_line=1

    # Calculate the end line
    end_line=$((line_number + CONTEXT_LINES))

    # Extract the context lines
    echo "Showing $CONTEXT_LINES lines of context around match:"
    echo "-------------------------------------------------------------"
    sed -n "${start_line},${end_line}p" "$DICTIONARY_FILE"
    echo "-------------------------------------------------------------"
    echo "Note: This is showing only a context window, not necessarily the complete entry."
else
    # Extract the full entry using awk
    # The pattern to detect the start of a new entry is complex - we look for lines that:
    # 1. Start with a Latin word (letters, possibly with diacritics)
    # 2. Followed by a comma and typical dictionary notation
    awk -v start="$line_number" '
        # When we reach our starting line, start capturing
        NR == start {
            in_entry = 1;
            print;
            next
        }

        # If we encounter what looks like the beginning of another entry, stop capturing
        # This pattern looks for dictionary headwords by detecting typical entry patterns
        in_entry && /^[a-zA-ZāēīōūȳăĕĭŏŭÿÄËÏÖÜŸäëïöüÿ][a-zA-ZāēīōūȳăĕĭŏŭÿÄËÏÖÜŸäëïöüÿ]*[,][ ][^,]*[,]/ {
            # Count the number of commas to distinguish between entry starts and normal sentences
            comma_count = gsub(/,/, ",");
            if (comma_count >= 2) {
                in_entry = 0;
                exit;
            }
        }

        # Alternative pattern for entry detection - look for typical dictionary notations
        in_entry && /^[a-zA-ZāēīōūȳăĕĭŏŭÿÄËÏÖÜŸäëïöüÿ][a-zA-ZāēīōūȳăĕĭŏŭÿÄËÏÖÜŸäëïöüÿ\-]*[ ]*(,|[.]|[(])/ {
            # This needs to be the first character of a line
            if (substr($0, 1, 1) ~ /[a-zA-ZāēīōūȳăĕĭŏŭÿÄËÏÖÜŸäëïöüÿ]/) {
                # But we need to avoid continuing text that happens to start with a capital
                if (length($1) <= 12) {  # Typical dictionary headwords are not too long
                    in_entry = 0;
                    exit;
                }
            }
        }

        # Continue capturing lines between start and end
        in_entry {print}
    ' "$DICTIONARY_FILE"
fi

echo "-------------------------------------------------------------"
echo "Entry found in: $DICTIONARY_FILE"
