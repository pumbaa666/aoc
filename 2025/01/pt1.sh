#!/bin/bash

source "$(dirname "$0")/../common.sh"

START_POSITION="50"
MAX_CADRANT_NUMBER="100"
declare operations

# Read input data
while IFS= read -r line; do
    operations+=("${line}")
done < "${PUZZLE_INPUT_FILE}"

readonly nb_operation="${#operations[@]}"
debug "Found ${nb_operation} operations"

# Main logic
accumulator=0

op_regex="([A-Z]+)([0-9]+)"
current_position="${START_POSITION}"
debug "Starting at : ${current_position}"
for((i = 0; i < nb_operation; i++)); do
    operation="${operations[i]}"

    if [[ ! ${operation} =~ ${op_regex} ]]; then
        debug "/!\\ Skipping ${operation}"
        continue
    fi

    # Split the operation into direction and value
    # match=${BASH_REMATCH[0]}
    direction=${BASH_REMATCH[1]}
    value=${BASH_REMATCH[2]}
    debug "Moving : $direction, $value times"

    # Apply the operation
    case "${direction}" in
        "L") ((current_position = (current_position - value) % MAX_CADRANT_NUMBER))
            debug "     Tmp new position : ${current_position}"
            if (( current_position < 0 )); then
                current_position=$((MAX_CADRANT_NUMBER + current_position))
                debug "     Adjusting to     : ${current_position}"
            fi
            ;;
        "R") ((current_position = (current_position + value) % MAX_CADRANT_NUMBER))
            debug "     Tmp new position : ${current_position}"
            if (( current_position >= MAX_CADRANT_NUMBER )); then
                current_position=$((current_position - MAX_CADRANT_NUMBER))
                debug "     Adjusting to     : ${current_position}"
            fi
            ;;
    esac
    debug "     New cadrant value : ${current_position}"
    if (( current_position == 0 )); then
        ((accumulator++))
    fi
done

debug "-------------------------"
echo "Nb zero : ${accumulator}"