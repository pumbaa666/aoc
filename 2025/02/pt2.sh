#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data
IFS=',' read -ra id_ranges < "${PUZZLE_INPUT_FILE}"
nb_range="${#id_ranges[@]}"
debug "Found ${nb_range} ranges"

# Returns 0 if number is valid (no repetition)
# Returns 1 otherwise
function check_validity() {
    local range_number=$1
    local nb_char=$2
    local nb_part=$3

    local first_part="${range_number:0:$nb_char}"
    debug "    nb char = $nb_char"
    debug "    first_part = \"$first_part\""

    local i next_part next_part_index
    for((i = 1; i < nb_part; i++)); do
        next_part_index=$((i * nb_char))
        next_part="${range_number:$next_part_index:$nb_char}"
        debug "      next_part = \"$next_part\""

        if [[ "${first_part}" != "${next_part}" ]]; then
            debug "  ${range_number} is valid"
            return 0
        fi
    done

    debug "  ${range_number} is invalid !!!"
    return 1
}

# Main logic
accumulator=0
for((range_index = 0; range_index < nb_range; range_index++)); do
    range="${id_ranges[range_index]}"
    echo "Processing range $((range_index+1)) / $nb_range (${range})"

    IFS='-' read -r lhs rhs <<< ${range}
    for((range_number = lhs; range_number <= rhs; range_number++));do
        debug "  testing $range_number"
        total_char="${#range_number}"
        for ((divisor = 2; divisor <= total_char; divisor++)); do
            nb_char=$((total_char / divisor))
            debug "    divisor = $divisor"
            if (( total_char != nb_char * divisor )); then
                debug "    the sub-part is not a divisor of total char (${total_char} != ${nb_char} * ${divisor})"
                continue
            fi

            check_validity "${range_number}" "${nb_char}" "${divisor}"
            if [[ $? == 0 ]]; then
                continue
            else
                ((accumulator+=range_number))
                continue 2
            fi
        done
    done
done

debug "-------------------------"
echo "Sum of invalid ID's : ${accumulator}"