#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data into a grid (associative array)
# The key are X,Y coordinates
NB_COLUMNS=0
NB_ROWS=0
declare -A grid
while IFS= read -r line; do
    NB_COLUMNS="${#line}"
    
    for((x = 0; x < NB_COLUMNS; x++)); do
        key="${x},${NB_ROWS}"
        grid[$key]="${line:x:1}"
    done

    ((NB_ROWS++))
done < "${PUZZLE_INPUT_FILE}"

function find_xmas() {
    local starting_pos=${1:-}
    local dx=${2:-}
    local dy=${3:-}

    [[ -z "${starting_pos}" ]] && fatal "starting_pos is empty" 10
    [[ "${dx}" =~ \-?[0-9]+ ]] || fatal "dx must be an integer" 10
    [[ "${dy}" =~ \-?[0-9]+ ]] || fatal "dy must be an integer" 10

    local next_x next_y
    IFS=, read -r next_x next_y <<< ${starting_pos}
    [[ "${next_x}" =~ [0-9]+ ]] || fatal "next_x must be an integer" 11
    [[ "${next_y}" =~ [0-9]+ ]] || fatal "next_y must be an integer" 11

    debug "next_x = ${next_x} / next_y = ${next_y} / dx = ${dx} / dy = ${dy}"

    local word="${grid[$starting_pos]}"
    local i next_char key
    for((i = 0; i < 3; i++)); do
        ((next_x += dx))
        ((next_y += dy))
        key="${next_x},${next_y}"
        next_char="${grid[$key]:-Z}" # Replace out-of-bounds with invalid char

        word="${word}${next_char}"
        if [[ ! "XMAS" =~ ${word}.* ]]; then
            debug "  ${word} is not XMAS"
            return 1
        fi
    done

    debug "  Found XMAS spirit !"
    return 0
}

# Main logic
xmas_found=0
for((y = 0; y < NB_ROWS; y++)); do
    for((x = 0; x < NB_COLUMNS; x++)); do
        key="${x},${y}"
        char="${grid[$key]}"
        if [[ "${char}" == "X" ]]; then
            debug
            # Check the 8 cardinal directions
            for((dx = -1; dx <= 1; dx++)); do
                for((dy = -1; dy <= 1; dy++)); do
                    ((dx == 0 && dy == 0)) && continue
                    find_xmas ${key} ${dx} ${dy} && ((xmas_found++))
                done
            done
        fi
    done
done

debug "-------------------------"
echo "XMAS found : ${xmas_found}"