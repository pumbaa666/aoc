#!/bin/bash

source "$(dirname "$0")/../common.sh"

START_POSITION="50"
MAX_CADRANT_NUMBER="99"
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
        "L") for((j = 0; j < value; j++)); do
                ((current_position--))
                if ((current_position == 0)); then
                    ((accumulator++))
                fi
                if ((current_position < 0)); then
                    current_position="${MAX_CADRANT_NUMBER}"
                fi
            done
            ;;
        "R") for((j = 0; j < value; j++)); do
                ((current_position++))
                if ((current_position == MAX_CADRANT_NUMBER+1 )); then
                    ((accumulator++))
                    current_position="0"
                fi
            done
    esac
    debug "     New cadrant value : ${current_position}"
done

debug "-------------------------"
echo "Nb zero : ${accumulator}"