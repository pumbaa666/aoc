#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data
declare -A rules
rules_regex="[0-9]+\|[0-9]"

reports=()
report_regex="[0-9]+,"

while IFS= read -r line; do
    if [[ "${line}" =~ ${rules_regex} ]]; then
        IFS='|' read -r lhs rhs <<< ${line}
        # rules[${lhs}]="${rhs}"
        rules[${rhs}]="${lhs}"
    elif [[ "${line}" =~ ${report_regex} ]]; then
        reports+=( ${line} )
    fi
done < "${PUZZLE_INPUT_FILE}"

print_array rules
# print_array reports

function get_middle_page_of_correct_report( {
    local report="${1:-}"
    debug "${report}"

    local i page next_page pages should_not_follow
    IFS=',' read -r -a pages <<< ${report}
    local nb_pages="${#pages[@]}"
    for((i = 0; i < nb_pages; i++)); do
        page="${pages[$i]}"
        # [[ -z "${page}" ]] && continue

        should_not_follow="${rules[$page]:-}"
        debug "  ${pages} should not follow ${should_not_follow}"
        # [[ -z "${should_not_follow}" ]] && continue
        # debug "${page}"
        # for((j = i + 1; j < nb_pages; j++)); do
        #     next_page="${pages[$j]}"
        #     debug "  ${next_page} should not follow ${should_not_follow}"
        #     if [[ "${next_page}" == "${should_not_follow}" ]]; then
        #         debug "  Abort, abooort"
        #         echo "0"
        #         return
        #     fi
        # done
    done

    local middle_page_index="$((nb_pages / 2))"
    local middle_page_value="${pages[$middle_page_index]}"
    # debug "report[$middle_page_index] = ${middle_page_value}"
    echo "${middle_page_value}"
})

# Main logic
nb_reports="${#reports[@]}"
accumulator=0
for((i = 3; i < nb_reports; i++)); do
    report="${reports[$i]}"
    middle_page="$(get_middle_page_of_correct_report ${report})"
    ((accumulator+=middle_page))

    # break
done

debug "-------------------------"
echo "Sum of middle pages : ${accumulator}"