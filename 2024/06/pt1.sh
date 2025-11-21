#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data into a grid (associative array)
# The key are X,Y coordinates
#   "^" is the starting location
#   "#" are obstacles
#   "." are free spaces
NB_COLUMNS=0
NB_ROWS=0
STARTING_LOCATION=""
STARTING_DIRECTION=""
declare -A GRID
declare -A VISITED
while IFS= read -r line; do
    NB_COLUMNS="${#line}"
    
    for((x = 0; x < NB_COLUMNS; x++)); do
        key="${x},${NB_ROWS}"
        char="${line:x:1}"
        case "${char}" in
            '^') STARTING_LOCATION="${key}"
                 STARTING_DIRECTION="${char}"
                 VISITED[$STARTING_LOCATION]="1"
                 char='.' # Starting location is a free space
                 ;;
        esac
        GRID[$key]="${char}"
    done

    ((NB_ROWS++))
done < "${PUZZLE_INPUT_FILE}"

function print_grid() {
    local current_location=${1}
    local current_direction=${2}

    local x y key char
    for((y = 0; y < NB_ROWS; y++)); do
        for((x = 0; x < NB_COLUMNS; x++)); do
            key="${x},${y}"
            if [[ "${key}" == "${current_location}" ]]; then
                char="${current_direction}"
            else
                char="${GRID[$key]}"
            fi
            echo -n "${char}" >& 2
        done
        echo "" >& 2
    done
}

function solve_maze() {
    local current_location=${1}
    local current_direction=${2}

    while true; do
        # Make a move
        IFS=',' read -r x y <<< ${current_location}
        case "${current_direction}" in
            '^') ((y--));;
            'v') ((y++));;
            '<') ((x--));;
            '>') ((x++));;
            *) fatal "Invalid direction : ${current_direction}" 10 ;;
        esac

        if (( x < 0  || x >= ${NB_COLUMNS} || y < 0  || y >= ${NB_ROWS} )); then
            # We're out  of bounds, the maze is solved
            return 0
        fi

        new_location="${x},${y}"
        char="${GRID[$new_location]}"
        if [[ "${char}" == "#" ]]; then
            # We've hit a wall, let's turn right
            case "${current_direction}" in
                '^') current_direction=">";;
                'v') current_direction="<";;
                '<') current_direction="^";;
                '>') current_direction="v";;
                *) fatal "Invalid direction : ${current_direction}" 10 ;;
            esac
        else
            # Moving to free space
            current_location="${new_location}"
            VISITED[$current_location]=1
        fi

        # clear
        # print_grid  "${current_location}" "${current_direction}"
        # sleep 0.1
    done

    echo "Maze is unsolvabled"
    return 1
}

print_grid "${STARTING_LOCATION}" "${STARTING_DIRECTION}"

# Main logic
solve_maze "${STARTING_LOCATION}" "${STARTING_DIRECTION}"

debug "-------------------------"
echo "Distinct positions visited : ${#VISITED[@]}"