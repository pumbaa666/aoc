#!/bin/bash

source "$(dirname "$0")/../common.sh"

INPUT=${1:-example-input.txt}
if [[ ! -f "${INPUT}" ]]; then
    fatal "Input file not found: ${INPUT}"
fi

# Read input data into REPORTS array
REPORTS=()
while IFS= read -r line; do
    read -r report <<< ${line}
    REPORTS+=("$report")
done < "${INPUT}"

nb_reports=${#REPORTS[@]}
for ((i = 0; i < nb_reports; i++)); do
    report=${REPORTS[i]}
    debug "Repport $i : $report"
done