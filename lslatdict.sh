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
    echo "  -d, --direct           Print directly to terminal (no external viewer)"
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
DIRECT_OUTPUT=false

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
        -d|--direct)
            DIRECT_OUTPUT=true
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

# Check if less exists
check_viewer() {
    if ! command -v "less" &> /dev/null; then
        echo "Warning: less not found. Falling back to direct output."
        DIRECT_OUTPUT=true
    fi
}

# Create a function to handle output to either temp file or terminal
output_result() {
    if [ "$DIRECT_OUTPUT" = true ]; then
        # Just print directly
        cat -
    else
        # Append to temp file
        cat - >> "$TEMP_FILE"
    fi
}

# Function to display output in less
display_output() {
    if [ "$DIRECT_OUTPUT" = false ] && [ -s "$TEMP_FILE" ]; then
        # Display the content using less
        less "$TEMP_FILE"
    fi
}

# Set up output method
if [ "$DIRECT_OUTPUT" = false ]; then
    # Create a temporary file that will persist until script ends
    TEMP_FILE=$(mktemp /tmp/lslatdict.XXXXXX)

    # Set up trap to clean up on exit
    trap 'rm -f "$TEMP_FILE"' EXIT

    check_viewer

    # Print to terminal that we're searching
    echo "Searching for '$SEARCH_WORD' in Lewis & Short Latin Dictionary..."
fi

# Start building output
{
    echo "Searching for '$SEARCH_WORD' in Lewis & Short Latin Dictionary..."
    echo "-------------------------------------------------------------"
} | output_result

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

# Function to search for the entry
find_headword() {
    local search_word="$1"
    local line_number=""

    # First attempt: try to find the exact word as a headword with a clear boundary
    # This specifically looks for dictionary headwords which are typically at the start of a line
    # and followed by a comma, period, or parenthesis
    pattern="^[[:space:]]*$search_word[[:space:]]*[,.(]"
    line_number=$(grep -n "$pattern" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)

    # If not found, try with diacritical flexibility
    if [ -z "$line_number" ]; then
        relaxed_pattern=$(create_diacritic_pattern "$search_word")
        pattern="^[[:space:]]*$relaxed_pattern[[:space:]]*[,.(]"
        line_number=$(grep -n "$pattern" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)
    fi

    # If still not found and not in exact match mode, try more flexible approaches
    if [ -z "$line_number" ] && [ "$EXACT_MATCH" != true ]; then
        # Try looking for common entry patterns like "ămo, āvi, ātum"
        pattern="^[[:space:]]*[ăāĕēĭīŏōŭū]?$search_word[[:space:]]*[,]"
        line_number=$(grep -n "$pattern" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)

        # Try with diacritical flexibility
        if [ -z "$line_number" ]; then
            relaxed_pattern=$(create_diacritic_pattern "$search_word")
            pattern="^[[:space:]]*[ăāĕēĭīŏōŭū]?$relaxed_pattern[[:space:]]*[,]"
            line_number=$(grep -n "$pattern" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)
        fi

        # Try looking for the word as part of a hyphenated or compound term at the start of entry
        if [ -z "$line_number" ] && [ ${#search_word} -gt 2 ]; then
            relaxed_pattern=$(create_diacritic_pattern "$search_word")
            pattern="^[[:space:]]*[^-]*$relaxed_pattern[^-]*[[:space:]]*[,.(]"
            line_number=$(grep -n "$pattern" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)
        fi

        # Try removing the last character (for declined/conjugated forms)
        if [ -z "$line_number" ] && [ ${#search_word} -gt 2 ]; then
            stem="${search_word%?}"
            stem_pattern=$(create_diacritic_pattern "$stem")
            pattern="^[[:space:]]*$stem_pattern[[:alpha:]]*[[:space:]]*[,.(]"
            line_number=$(grep -n "$pattern" "$DICTIONARY_FILE" | head -1 | cut -d: -f1)
        fi
    fi

    echo "$line_number"
}

# Find the headword entry
line_number=$(find_headword "$SEARCH_WORD")

# If we still haven't found the word, try to provide suggestions if enabled
if [ -z "$line_number" ]; then
    {
        echo "No entry found for '$SEARCH_WORD'."
        echo "Try checking the spelling or searching for a different form of the word."

        if [ "$SUGGEST" = true ]; then
            echo ""
            echo "Possible related entries:"
            relaxed_pattern=$(create_diacritic_pattern "$SEARCH_WORD")
            grep -i "^[[:space:]]*$relaxed_pattern" "$DICTIONARY_FILE" | head -5

            # If nothing found with prefix, try substring match
            if [ -z "$(grep -i "^[[:space:]]*$relaxed_pattern" "$DICTIONARY_FILE" | head -1)" ]; then
                echo ""
                echo "Or perhaps one of these entries contains your word:"
                grep -i "^[[:space:]]*[a-zA-ZāēīōūȳăĕĭŏŭÿÄËÏÖÜŸäëïöüÿ]*[[:space:]]*[,.(].*$SEARCH_WORD" "$DICTIONARY_FILE" | head -5
            fi
        fi
    } | output_result

    # Display the results if using a viewer
    display_output
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
    {
        echo "Showing $CONTEXT_LINES lines of context around match:"
        echo "-------------------------------------------------------------"
        sed -n "${start_line},${end_line}p" "$DICTIONARY_FILE"
        echo "-------------------------------------------------------------"
        echo "Note: This is showing only a context window, not necessarily the complete entry."
    } | output_result
else
    # Extract the full entry using awk with improved logic for dictionary entries
    {
        awk -v start="$line_number" '
            # When we reach our starting line, start capturing
            NR == start {
                in_entry = 1;
                print;
                next
            }

            # Detect the start of a new dictionary entry by identifying headword patterns
            in_entry && /^[[:space:]]*[a-zA-ZāēīōūȳăĕĭŏŭÿÄËÏÖÜŸäëïöüÿ][a-zA-ZāēīōūȳăĕĭŏŭÿÄËÏÖÜŸäëïöüÿ\-]*[[:space:]]*[,.(]/ {
                # This needs to be the first real character of a line
                if ($0 ~ /^[[:space:]]*[a-zA-ZāēīōūȳăĕĭŏŭÿÄËÏÖÜŸäëïöüÿ]/) {
                    # Check if this looks like a dictionary headword entry
                    # First, get the word by removing everything after the first comma, period, etc.
                    word = $0
                    sub(/[[:space:]]*[,.(].*$/, "", word)
                    # Remove leading/trailing spaces
                    gsub(/^[[:space:]]+|[[:space:]]+$/, "", word)

                    # If the word is short enough and has no spaces, it might be a headword
                    if (length(word) <= 15 && word !~ / /) {
                        in_entry = 0
                        exit
                    }
                }
            }

            # Continue capturing lines between start and end
            in_entry {print}
        ' "$DICTIONARY_FILE"
    } | output_result
fi

{
    echo "-------------------------------------------------------------"
    echo "Entry found in: $DICTIONARY_FILE"
} | output_result

# Display the results if using a viewer
display_output
