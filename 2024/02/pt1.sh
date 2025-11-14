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

function check_report_is_safe () {
    # Safety checks
    local report_str=${1:-}
    [[ -z ${report_str} ]] && fatal "check_report_is_safe : report_str should not be null" 10

    local report
    IFS=' ' read -r -a report <<< "${report_str}"
    local report_len=${#report[@]}
    debug 
    debug "${report[@]} (len=${report_len})"
    ((report_len <= 0)) && fatal "Report should have at least one element" 11

    # Get first elem and initial direction
    local current_elem=${report[0]}
    local second_elem=${report[1]}
    local diff=$((second_elem - current_elem))
    local initial_direction="+"
    [[ "${diff}" =~ ^\-.* ]] && initial_direction="-"

    # Check the whole report
    local i next_elem direction
    for ((i = 1; i < report_len; i++)); do
        next_elem=${report[i]}
        diff=$((next_elem - current_elem))
        
        [[ "${diff}" =~ ^\-.* ]] && direction="-" || direction="+"
        if [[ "${initial_direction}" != "${direction}" ]]; then
            debug " > changing direction"
            return 1
        fi

        diff=${diff#-}  # absolute value
        debug " > diff : $diff"
        if (( diff > 3 )); then
            debug " > Too high"
            return 1
        elif (( diff == 0 )); then
            debug " > Cannot be the same number"
            return 1
        fi

        current_elem=${next_elem}
    done

    debug "This one is safe"
    return 0
}

nb_reports=${#REPORTS[@]}
nb_safe_reports=0
for ((i = 0; i < nb_reports; i++)); do
    report=${REPORTS[i]}
    check_report_is_safe "${report}"
    [[ $? == 0 ]] && ((nb_safe_reports++))
done

debug "-------------------------"
echo "Nb safe reports : ${nb_safe_reports}"
