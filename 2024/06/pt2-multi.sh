#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data into a grid (associative array)
# The key are X,Y coordinates
#   "^" is the guard starting location, facing up
#   "#" are obstacles
#   "." are free spaces
#   "X" are vivsited free spaces
NB_COLUMNS=0
NB_ROWS=0
STARTING_LOCATION=""
STARTING_DIRECTION=""
NB_BG_PROCESS=$(nproc --all 2>/dev/null || echo 8)
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
                 VISITED[$STARTING_LOCATION]="^" # Save the facing direction into visited spot
                 char='.' # Starting location is a free space
                 ;;
        esac
        GRID[$key]="${char}"
    done

    ((NB_ROWS++))
done < "${PUZZLE_INPUT_FILE}"

function clean_terminal() {
    if [[ "${DEBUG}" == "anim" ]]; then
        # Print the next lines below the maze ($NB_ROWS)
        TPUT_HOME=$(tput cup ${NB_ROWS} 0)
        printf '%s%s' "${TPUT_HOME}" "${TPUT_ED}"
        tput cnorm # Restore cursor
    fi
}

# Capture SIGINT (ctrl-C) interruption to clean the terminal before exiting
function signal_handler() {
    clean_terminal
    exit 0
}

function solve_maze() {
    local current_location=${1}
    local current_direction=${2}
    local obstacle_location=${3}
    
    GRID[$obstacle_location]="#"

    local x y
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

        local new_location="${x},${y}"
        local char="${GRID[$new_location]}"
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

            # If we already visited this spot facing that direction...
            if [[ "${VISITED[$current_location]:-X}" == *${current_direction}* ]]; then
                # ... we are stuck !
                return 1
            else
                # Add the facing direction to the visited spots
                VISITED[$current_location]="${VISITED[$current_location]:-}${current_direction}"
            fi
        fi
    done
}

# Main logic
nb_blocking_maze=0
i=0
total_combination=$(( NB_ROWS * NB_COLUMNS ))
declare bg_process_pid
for((y = 0; y < NB_ROWS; y++)); do
    for((x = 0; x < NB_COLUMNS; x++)); do
        ((i++))
        debug
        debug "Spawning process ${i} / ${total_combination}"
        # debug "(nb jobs : $(jobs | wc -l))"

        key="${x},${y}"
        [[ "${key}" == "${STARTING_LOCATION}" || "${GRID[$key]}" == "#" ]] && continue

        (solve_maze "${STARTING_LOCATION}" "${STARTING_DIRECTION}" "${key}") & bg_process_pid+=($!)

        while (( $(jobs | wc -l) >= "${NB_BG_PROCESS}" )); do
            debug "waiting a bit. Nb jobs : $(jobs | wc -l)";
            sleep 0.15;
            # debug "  after : $(jobs | wc -l)"
        done
    done
done

print_array bg_process_pid
nb_pid="${#bg_process_pid[@]}"
for((i = 0; i < nb_pid; i++)); do
    pid="${bg_process_pid[$i]}"
    debug "Waiting for bg process PID: ${pid} (${i} / ${nb_pid})"
    wait ${pid}
    result=$?
    ((nb_blocking_maze+=result))
done

clean_terminal
echo "Nb possible obstacle : ${nb_blocking_maze}"
