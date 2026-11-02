#!/bin/bash

source "$(dirname "$0")/../common.sh"
COLOR_RED=$(tput setaf 1)
COLOR_RESET=$(tput sgr0)

# Read input data
START_LOCATION=""
declare -A grid
y=0
while IFS= read -r line; do
    nb_char="${#line}"
    for((x = 0; x < nb_char; x++));do
        char="${line:$x:1}"
        key="${x},${y}"
        [[ "${char}" == "S" ]] && START_LOCATION="${key}"
        [[ "${char}" == "." ]] && char=" "
        grid[$key]="${char}"
    done

    ((y++))
done < "${PUZZLE_INPUT_FILE}"
WIDTH="${nb_char}"
HEIGHT="${y}"

function clean_terminal() {
    if [[ "${DEBUG}" == "anim" ]]; then
        # Print the next lines below the maze ($HEIGHT)
        TPUT_HOME=$(tput cup ${HEIGHT} 0)
        printf '%s%s' "${TPUT_HOME}" "${TPUT_ED}" >&2
        tput cnorm # Restore cursor
    fi
}

# Capture SIGINT (ctrl-C) interruption to clean the terminal before exiting
function signal_handler() {
    clean_terminal
    exit 0
}

function print_grid() {
    local current_y="${1:-0}"

    # Calculate bounds to only print a portion of the maze to fit in the terminal, centered on our current location
    local left_bound="0"
    local right_bound="${WIDTH}" # Not SCREEN_WIDTH, we'll print the whole line, since it fit
    local up_bound=$((current_y - SCREEN_HEIGHT / 2))
    (( up_bound < 0 )) && up_bound=0
    local down_bound=$((current_y + SCREEN_HEIGHT / 2 - 1)) # -1 to let a space for the current visited location
    (( down_bound > HEIGHT )) && down_bound=${HEIGHT}

    local x y key char beam line
    for((y = up_bound; y < down_bound; y++)); do
        line=""
        for((x = left_bound; x < right_bound; x++)); do
            key="${x},${y}"
            beam="${beams[$key]:-}"
            if [[ "${beam}" == "1" ]]; then
                char="${COLOR_RED}|${COLOR_RESET}"
            elif [[ "${key}" == "${START_LOCATION}" ]]; then
                char="S"
            else
                char="${grid[$key]}"
            fi
            line="${line}${char}"
        done
        printf '%s%s\n' "$line" "$TPUT_EL" >&2
    done
    printf '%s%s%s' "[Nb beams : ${#beams[@]}] / [Nb splits : ${nb_split}]" "${TPUT_ED}" "${TPUT_HOME}" >&2
}

# Init screen (for clever echo without flickering)
if [[ "${DEBUG}" == "anim" ]]; then
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
nb_split=0

clear
declare -A beams
IFS=',' read -r beam_x beam_y <<< "${START_LOCATION}"
starting_beam="${beam_x},$((beam_y + 1))"
beams[$starting_beam]="1"
nb_running_beams=1
debug "Fire beam at ${starting_beam} (${beams[$starting_beam]})"
if [[ "${DEBUG}" == "anim" ]]; then
    print_grid
    sleep "${ANIMATION_SLEEP_TIME}"
fi

# Run all beams
while ((nb_running_beams > 0)); do
    debug "Nb running beams : ${nb_running_beams}"
    for key in "${!beams[@]}"; do
        IFS=',' read -r beam_x beam_y <<< "${key}"
        beam_new_x="${beam_x}"
        beam_new_y="$((beam_y + 1))"
        if (( beam_new_y >= HEIGHT )); then
            unset beams[$key]
            continue
        fi

        new_key="${beam_new_x},${beam_new_y}"

        char="${grid[$new_key]}"
        case "${char}" in
            '^') ((nb_split++))
                if ((beam_x > 0)); then
                    beam_new_x="$((beam_x - 1))"
                    new_key="${beam_new_x},${beam_new_y}"
                    beams[$new_key]="1"
                    unset beams[$key]
                fi
                if ((beam_x < WIDTH)); then
                    beam_new_x="$((beam_x + 1))"
                    new_key="${beam_new_x},${beam_new_y}"
                    beams[$new_key]="1"
                    unset beams[$key]
                fi
                ;;
            
            ' ')
                beams[$new_key]="1"
                unset beams[$key]
                ;;

            *) fatal "Unknown char '${char}'" 2;;
        esac
    done

    nb_running_beams="${#beams[@]}"
    if [[ "${DEBUG}" == "anim" ]]; then
        print_grid "${beam_new_y}"
        sleep "${ANIMATION_SLEEP_TIME}"
    fi
done

clean_terminal
debug "-------------------------"
echo "A tachyon beam is split a total of ${nb_split} times"