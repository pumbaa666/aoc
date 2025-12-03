#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data
IFS=',' read -ra id_ranges < "${PUZZLE_INPUT_FILE}"
readonly nb_range="${#id_ranges[@]}"
debug "Found ${nb_range} ranges"

# Main logic
accumulator=0
for((i = 0; i < nb_range; i++));do
    range="${id_ranges[i]}"
    debug "Processing range $((i+1)) / $nb_range"

    IFS='-' read -r lhs rhs <<< ${range}
    # debug "    from $lhs to $rhs"
    for((j = lhs; j <= rhs; j++));do
        total_char="${#j}"
        half_char=$((total_char / 2))
        first_half="${j:0:$half_char}"
        second_half="${j:$half_char}"
        # debug "  $j : total_char = $total_char / half_char = $half_char"
        # debug "  $j : first_half = $first_half / second_half = $second_half"

        if [[ "${first_half}" == "${second_half}" ]]; then
            debug "  $j is invalid "
            ((accumulator+=j))
        fi
    done
done

debug "-------------------------"
echo "Sum of invalid ID's : ${accumulator}"