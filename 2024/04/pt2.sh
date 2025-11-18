#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data into a grid (associative array)
# The key are X,Y coordinates
nb_columns=0
nb_rows=0
declare -A grid
while IFS= read -r line; do
    nb_columns="${#line}"
    
    for((x = 0; x < nb_columns; x++)); do
        key="${x},${nb_rows}"
        grid[$key]="${line:x:1}"
    done

    ((nb_rows++))
done < "${PUZZLE_INPUT_FILE}"

# Check in a 3x3 square, coordinate going from starting_pos.x, starting_pos.y to starting_pos.x+2, starting_pos.y+2
function find_xmas() {
    local start_x=${1:-}
    local start_y=${2:-}

    [[ ${start_x} =~ [0-9]+ ]] || fatal "start_x must be an integer" 11
    [[ ${start_y} =~ [0-9]+ ]] || fatal "start_y must be an integer" 11

    # Top left
    local key="${start_x},${start_y}"
    local top_left="${grid[$key]}"
    debug "Getting 3x3 square, top left : ${start_x},${start_y} = ${top_left}"

    local opposite_side
    case "${top_left}" in
        M)  opposite_side="S" ;;
        S)  opposite_side="M" ;;
        *)  debug "  Top-left is not even M or S (is ${top_left})"
            return 1;;
    esac

    # Center
    local next_x=$((start_x + 1))
    local next_y=$((start_y + 1))
    key="${next_x},${next_y}"
    local center_char="${grid[$key]:-Z}"
    if [[ "${center_char}" != "A" ]]; then
        debug "  Center is not even A (is ${center_char})"
        return 1
    fi

    # Top right
    next_x=$((start_x + 2))
    next_y=$((start_y))
    key="${next_x},${next_y}"
    local top_right="${grid[$key]}"

    # Bottom left
    next_x=$((start_x))
    next_y=$((start_y + 2))
    key="${next_x},${next_y}"
    local bottom_left="${grid[$key]}"
    if [[ ("${top_left}" == "${top_right}" && "${bottom_left}" == "${opposite_side}") || \
          ("${top_left}" == "${bottom_left}" && "${top_right}" == "${opposite_side}") ]]; then
        debug "  Checking top-left vs other corner : ok for now"
    else
        debug "  No matching top-left corner. ${top_left} vs ${top_right} and ${bottom_left}"
        return 1
    fi

    # Bottom right
    next_x=$((start_x + 2))
    next_y=$((start_y + 2))
    key="${next_x},${next_y}"
    local bottom_right="${grid[$key]}"
    if [[ "${bottom_right}" != "${opposite_side}" ]]; then
        debug "  Bottom-right is not opposite. ${bottom_right} vs ${opposite_side}"
        return 1
    fi

    debug "  Found XMAS spirit !"
    return 0
}

# Main logic
xmas_found=0
for((y = 0; y < nb_rows-2; y++)); do
    for((x = 0; x < nb_columns-2; x++)); do
        debug
        find_xmas ${x} ${y} && ((xmas_found++))
    done
done

debug "-------------------------"
echo "X-MAS found : ${xmas_found}"