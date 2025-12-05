#!/bin/bash

source "$(dirname "$0")/../common.sh"

banks=()
NB_BATTERY_POWERED_ON=12

# Read input data
while IFS= read -r line; do
    banks+=( ${line} )
done < "${PUZZLE_INPUT_FILE}"

# Main logic
function max_joltage() {
    local bank=$1
    local max_joltage="0"
    local remaining_batteries_to_power_on=${NB_BATTERY_POWERED_ON}
    local nb_battery="${#bank}"

    local powered_on_batteries=()

    local i j battery
    local index_start index_end
    local highest_index=-1
    for((j = 0; j < NB_BATTERY_POWERED_ON; j++)); do
        # Find highest battery in bank, excluding the remaining_batteries_to_power_on last batteries
        local highest_battery=0
        
        index_start=$((highest_index+1))
        index_end=$((nb_battery - remaining_batteries_to_power_on + 1))
        debug "  [$j] looking between batteries #${index_start} and #${index_end}"
        for((i = index_start; i < index_end; i++)); do
            battery="${bank:i:1}"
            if ((battery > highest_battery)); then
                highest_battery=${battery}
                highest_index=${i}
            fi
        done

        debug "  [$j] Highest: ${highest_battery}"
        powered_on_batteries+=(${highest_battery})
        ((remaining_batteries_to_power_on--))
    done

    IFS=; echo "${powered_on_batteries[*]}" # Print whole array without space between elements
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