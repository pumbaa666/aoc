#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data
declare -A RULES
readonly rules_regex="[0-9]+\|[0-9]"

REPORTS=()
INCORRECT_REPORTS=()
readonly report_regex="[0-9]+,"

while IFS= read -r line; do
    if [[ "${line}" =~ ${rules_regex} ]]; then
        IFS='|' read -r lhs rhs <<< ${line}
        RULES["${rhs}|${lhs}"]="1"
    elif [[ "${line}" =~ ${report_regex} ]]; then
        REPORTS+=( ${line} )
    fi
done < "${PUZZLE_INPUT_FILE}"

function check_report_validity() {
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
                return 1
            fi
        done
    done

    return 0
}

function order_and_get_middle_page_of_incorrect_report() {
    local report="${1:-}"
    debug "${report}"

    local pages
    IFS=',' read -r -a pages <<< ${report}
    local nb_pages="${#pages[@]}"
    
    local i j page next_page key rule
    for((i = 0; i < nb_pages; i++)); do
        # TODO
        page="${pages[$i]}"
        # for((j = i + 1; j < nb_pages; j++)); do
        #     next_page="${pages[$j]}"
        #     key="${page}|${next_page}"
        #     rule="${RULES[$key]:-0}"
        #     if [[ "${rule}" == "1" ]]; then
        #         debug "  ${page} should not follow ${next_page}. RULES[${key}] : ${rule}"
        #         echo "0"
        #         return
        #     fi
        # done
    done

    local middle_page_index="$((nb_pages / 2))"
    local middle_page_value="${pages[$middle_page_index]}"
    debug "Okay desu ! pages[${middle_page_index}] = ${middle_page_value}"
    echo "${middle_page_value}"
}

# Main logic
nb_reports="${#REPORTS[@]}"
for((i = 0; i < nb_reports; i++)); do
    report="${REPORTS[$i]}"
    check_report_validity "${report}" || INCORRECT_REPORTS+=("${report}")
done

print_array INCORRECT_REPORTS

nb_reports="${#INCORRECT_REPORTS[@]}"
accumulator=0
for((i = 0; i < nb_reports; i++)); do
    report="${INCORRECT_REPORTS[$i]}"
    middle_page="$(order_and_get_middle_page_of_incorrect_report ${report})"
    ((accumulator+=middle_page))
done

debug "-------------------------"
echo "Sum of middle pages : ${accumulator}"