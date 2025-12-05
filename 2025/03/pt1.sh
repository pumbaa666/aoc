#!/bin/bash

source "$(dirname "$0")/../common.sh"

banks=()

# Read input data
while IFS= read -r line; do
    banks+=( ${line} )
done < "${PUZZLE_INPUT_FILE}"

# Main logic
function max_joltage() {
    local bank=$1
    local max_joltage="0"

    # Find highest battery in bank, excluding last battery
    local nb_battery="${#bank}"
    local highest_battery=0
    local highest_index=0
    local i battery
    for((i = 0; i < nb_battery - 1; i++)); do
        battery="${bank:i:1}"
        if ((battery > highest_battery)); then
            highest_battery=${battery}
            highest_index=${i}
        fi
    done
    local first_highest=${highest_battery}
    debug "  First: ${first_highest}"

    # From that index, find highest battery in resulting string
    highest_battery=0
    for((i = highest_index + 1; i < nb_battery; i++)); do
        battery="${bank:i:1}"
        if ((battery > highest_battery)); then
            highest_battery=${battery}
            highest_index=${i}
        fi
    done
    local second_highest=${highest_battery}
    debug "  Second: ${second_highest}"
    debug "  Total: ${first_highest}${second_highest}"

    echo "${first_highest}${second_highest}"
}

nb_banks="${#banks[@]}"
accumulator=0
for((i = 0; i < nb_banks; i++)); do
    bank=${banks[i]}
    debug "Processing bank $((i+1)) / $nb_banks : ${bank}"

    max_joltage=$(max_joltage "${bank}")
    ((accumulator+=max_joltage))
done

debug "-------------------------"
echo "Sum of joltage : ${accumulator}"