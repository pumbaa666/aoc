#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data
fresh_ranges=()
while IFS= read -r line; do
    [[ -z "${line}" ]] && break
    fresh_ranges+=( ${line} )
done < "${PUZZLE_INPUT_FILE}"

nb_ranges="${#fresh_ranges[@]}"
debug "Found ${nb_ranges} ranges"

# Main logic
# Unify ranges (flatten overlaps)
modified="true"
nb_pass=0
while [[ "${modified}" == "true" ]]; do
    ((nb_pass++))
    debug "Pass # ${nb_pass}"
    modified="false"
    for((i = 0; i < nb_ranges; i++)); do
        range="${fresh_ranges[i]}"
        [[ -z "${range}" ]] && continue

        debug "  Checking ${range} (${i}/$((nb_ranges-1)))"
        IFS='-' read -r range_start range_end <<< "${range}"
        for((j = 0; j < nb_ranges; j++)); do
            ((i == j)) && continue
            range2="${fresh_ranges[j]}"
            [[ -z "${range2}" ]] && continue
            debug "    overlapping with ${range2} (${j}/$((nb_ranges-1)))"

            IFS='-' read -r range2_start range2_end <<< "${range2}"

            if ((range_start >= range2_start && range_start <= range2_end)); then
                debug "    YES+ : Modifying range #${i} from ${fresh_ranges[$i]} to ${range2_start}-${range_end}"
                fresh_ranges[$i]="${range2_start}-${range_end}"
                debug "    unsetting range[$j] from '${fresh_ranges[$j]}' to ''"
                fresh_ranges[$j]=""
                range_start="${range2_start}"
                modified="true"
            fi
            if ((range_end >= range2_start && range_end <= range2_end)); then
                debug "    YES- : Modifying range #${i} from ${fresh_ranges[$i]} to ${range_start}-${range2_end}"
                fresh_ranges[$i]="${range_start}-${range2_end}"
                debug "    unsetting range[$j] from '${fresh_ranges[$j]}' to ''"
                fresh_ranges[$j]=""
                range_end="${range2_end}"
                modified="true"
            fi
        done
    done
done

# Count
nb_fresh_ingredients=0
for((i = 0; i < nb_ranges; i++)); do
    range="${fresh_ranges[i]}"
    [[ -z "${range}" ]] && continue

    IFS='-' read -r range_start range_end <<< "${range}"
    diff=$((range_end - range_start + 1))
    ((nb_fresh_ingredients+=diff))
done

debug "-------------------------"
echo "There is ${nb_fresh_ingredients} fresh ingredients"