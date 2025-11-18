#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data
while IFS= read -r line; do
    read -r array <<< ${line}
done < "${PUZZLE_INPUT_FILE}"

# Main logic
accumulator=0

debug "-------------------------"
echo "Total : ${accumulator}"