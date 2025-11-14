#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data into REPORTS array
REPORTS=()
while IFS= read -r line; do
    read -r report <<< ${line}
    REPORTS+=("$report")
done < "${PUZZLE_INPUT_FILE}"

function check_report_is_safe () {
    # Safety checks
    local report_str=${1:-}
    local already_failed=${2:-}
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
    local i next_elem direction fail failing_index
    for ((i = 1; i < report_len; i++)); do
        failing_index=""
        next_elem=${report[i]}
        diff=$((next_elem - current_elem))
        
        [[ "${diff}" =~ ^\-.* ]] && direction="-" || direction="+"
        if [[ "${initial_direction}" != "${direction}" ]]; then
            debug " > changing direction"
            failing_index="${i}"
            break
        fi

        diff=${diff#-}  # absolute value
        debug " > diff : $diff"
        if (( diff > 3 )); then
            debug " > Too high"
            failing_index="${i}"
            break
        elif (( diff == 0 )); then
            debug " > Cannot be the same number"
            failing_index="${i}"
            break
        fi

        current_elem=${next_elem}
    done

    if [[ -n "${failing_index}" ]]; then
        # Check if this report already failed
        debug " >> Failing : index = ${failing_index} (${report[$failing_index]})"
        if [[ "${already_failed}" == "true" ]]; then
            debug " >> this report already failed !\n"
            return 1
        fi

        # If not, remove each element one at a time and check it again
        local initial_report=("${report[@]}") # Save initial report array
        local j
        for ((j = 0; j < report_len; j++)); do
            report=("${initial_report[@]}") # Reset array to initial value
            unset report[$j] # Remove one element at a time
            report_str="${report[@]}"
            debug " >> sub report to check : ${report_str}"
            check_report_is_safe "${report_str}" "true"
            if [[ $? == 0 ]]; then
                debug "This one is finally safe by removing index $j (${initial_report[$j]})"
                return 0
            fi
        done

        # No way to make it safe
        debug " >> No way to make it safe"
        return 1
    fi

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
