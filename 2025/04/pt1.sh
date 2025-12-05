#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data
declare -A grid
y=0
while IFS= read -r line; do
    nb_char="${#line}"
    for((x = 0; x < nb_char; x++)); do
        key="$x,$y"
        char="${line:x:1}"
        grid[$key]="${char}"
    done

    ((y++))
done < "${PUZZLE_INPUT_FILE}"
height=$y
width=$nb_char

# Main logic
function can_move() {
    local x_start=$1
    local y_start=$2
    local key_start="${x_start},${y_start}"
    local char_start="${grid[$key_start]}"
    [[ "${char_start}" != "@" ]] && return 1 # Don't try to move empty space
    
    local nb_surrounding_rolls=0
    local x y key char
    for((y = y_start - 1; y <= y_start + 1; y++)); do
        for((x = x_start - 1; x <= x_start + 1; x++)); do
            ((x < 0 || y < 0|| x >= width || y >= height)) && continue # Don't go out of bounds
            ((x == x_start && y == y_start)) && continue # Skip center roll

            key="${x},${y}"
            char="${grid[$key]}"
            [[ "${char}" == "@" ]] && ((nb_surrounding_rolls++))
        done
    done

    if ((nb_surrounding_rolls > 3)); then
        # Can't move this one, too much rolls around it
        return 1
    else
        # Can do !
        debug "Can move [$key_start]"
        return 0
    fi
}

accumulator=0
for((y = 0; y < height; y++)); do
    for((x = 0; x < width; x++)); do
        can_move "${x}" "${y}" && ((accumulator++))
    done
done

debug "-------------------------"
echo "there are ${accumulator} rolls of paper that can be accessed by a forklift"