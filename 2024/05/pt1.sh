#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data
declare -A RULES
readonly rules_regex="[0-9]+\|[0-9]"

REPORTS=()
readonly report_regex="[0-9]+,"

while IFS= read -r line; do
    if [[ "${line}" =~ ${rules_regex} ]]; then
        IFS='|' read -r lhs rhs <<< ${line}
        RULES["${rhs}|${lhs}"]="1"
    elif [[ "${line}" =~ ${report_regex} ]]; then
        REPORTS+=( ${line} )
    fi
done < "${PUZZLE_INPUT_FILE}"

function get_middle_page_of_correct_report() {
    local report="${1:-}"
    debug "${report}"

    local pages
    IFS=',' read -r -a pages <<< ${report}
    local nb_pages="${#pages[@]}"
    
    local i j page next_page key rule
    for((i = 0; i < nb_pages; i++)); do
        page="${pages[$i]}"
        for((j = i + 1; j < nb_pages; j++)); do
            next_page="${pages[$j]}"
            key="${page}|${next_page}"
            rule="${RULES[$key]:-0}"
            if [[ "${rule}" == "1" ]]; then
                debug "  ${page} should not follow ${next_page}. RULES[${key}] : ${rule}"
                echo "0"
                return
            fi
        done
    done

    local middle_page_index="$((nb_pages / 2))"
    local middle_page_value="${pages[$middle_page_index]}"
    debug "Okay desu ! pages[${middle_page_index}] = ${middle_page_value}"
    echo "${middle_page_value}"
}

# Main logic
nb_reports="${#REPORTS[@]}"
accumulator=0
for((i = 0; i < nb_reports; i++)); do
    report="${REPORTS[$i]}"
    middle_page="$(get_middle_page_of_correct_report ${report})"
    ((accumulator+=middle_page))
done

debug "-------------------------"
echo "Sum of middle pages : ${accumulator}"