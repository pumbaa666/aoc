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
INIT_GRID_SNAPSHOT=$(declare -p GRID | sed 's/^declare /declare -g /') # Add "-g" to declare it globaly, or else it will be declare it locally in the reset_grid function


function clean_terminal() {
    if [[ "${DEBUG}" == "true" ]]; then
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

function reset_grid() {
    VISITED=()
    VISITED[$STARTING_LOCATION]="^"

    GRID=()
    eval "${INIT_GRID_SNAPSHOT}"
    # echo "Reseting GRID with '$INIT_GRID_SNAPSHOT'" >&2
    # print_array GRID
}

function print_grid() {
    local current_location="${1}"
    local current_direction="${2}"

    local current_x current_y
    IFS=',' read -r current_x current_y <<< ${current_location}

    # Calculate bounds to only print a portion of the maze to fit in the terminal, centered on our current location
    local left_bound=$((current_x - SCREEN_WIDTH / 2))
    (( left_bound < 0 )) && left_bound=0
    local right_bound=$((current_x + SCREEN_WIDTH / 2))
    (( right_bound > NB_COLUMNS )) && right_bound=${NB_COLUMNS}
    local up_bound=$((current_y - SCREEN_HEIGHT / 2))
    (( up_bound < 0 )) && up_bound=0
    local down_bound=$((current_y + SCREEN_HEIGHT / 2 - 1)) # -1 to let a space for the current visited location
    (( down_bound > NB_ROWS )) && down_bound=${NB_ROWS}

    # Print the portion of the grid, centred on the guard (current_location)
    local x y key char line
    for((y = up_bound; y < down_bound; y++)); do
        line=""
        for((x = left_bound; x < right_bound; x++)); do
            key="${x},${y}"
            # debug "  printing '$key'"
            if [[ "${key}" == "${current_location}" ]]; then
                char="${current_direction}"
            elif [[ -n ${VISITED[$key]:-} ]]; then
                char="X"
            else
                char="${GRID[$key]}"
            fi
            line="${line}${char}"
        done
        printf '%-*.*s%s\n' ${TPUT_COLS} ${TPUT_COLS} "${line}" "${TPUT_EL}"
    done
    printf '%s%s%s' "[Blocking : ${nb_blocking_maze}]" "${TPUT_ED}" "${TPUT_HOME}"
}

function solve_maze() {
    local current_location=${1}
    local current_direction=${2}

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
        if [[ "${char}" == "#" || "${char}" == "O" ]]; then
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

        if [[ "${DEBUG}" == "true" ]]; then
            print_grid  "${current_location}" "${current_direction}"
            sleep 0.05
        fi
    done
}

# Init screen (for clever echo without flickering)
if [[ "${DEBUG}" == "true" ]]; then
    clear
    trap signal_handler INT
    tput civis    # hide cursor
    SCREEN_HEIGHT=$(tput lines)
    SCREEN_WIDTH=$(tput cols)
    TPUT_HOME=$(tput cup 0 0)
    TPUT_ED=$(tput ed)
    TPUT_EL=$(tput el)
    # ROWS=$(tput lines)
    TPUT_COLS=$(tput cols)
fi

# Main logic
nb_blocking_maze=0
blocking_maze=()
i=0
total_combination=$(( NB_ROWS * NB_COLUMNS ))
for((y = 0; y < NB_ROWS; y++)); do
    for((x = 0; x < NB_COLUMNS; x++)); do
        ((i++))
        echo "$i / $total_combination" >&2
        reset_grid

        key="${x},${y}"
        [[ "${key}" == "${STARTING_LOCATION}" || "${GRID[$key]}" == "#" ]] && continue

        # debug "Putting an obstacle at ${key}"
        GRID[$key]="O"
        solve_maze "${STARTING_LOCATION}" "${STARTING_DIRECTION}"
        if [[ $? == 1 ]]; then
            ((nb_blocking_maze++))
            blocking_maze+=($key)
        fi
    done
done

clean_terminal
echo "Nb possible obstacle : ${nb_blocking_maze}"
# printf "%s\n" "${blocking_maze[@]}"