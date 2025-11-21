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

# Parallelizable function
# https://stackoverflow.com/questions/25909718/return-code-of-background-process-bash
function order_and_get_middle_page_of_incorrect_report() (
    local report="${1:-}"
    debug "Sorting ${report}"

    local pages
    IFS=',' read -r -a pages <<< ${report}
    local nb_pages="${#pages[@]}"
    
    local i j page next_page key rule tmp
    for((i = 0; i < nb_pages; i++)); do
        page="${pages[$i]}"
        for((j = i + 1; j < nb_pages; j++)); do
            next_page="${pages[$j]}"
            key="${page}|${next_page}"
            rule="${RULES[$key]:-0}"
            if [[ "${rule}" == "1" ]]; then
                debug "  Swapping ${page} (idx: ${i}) and ${next_page} (idx: ${j})"
                tmp="${pages[$i]}"
                pages[$i]="${pages[$j]}"
                pages[$j]="${tmp}"
                local sorted_pages="${pages[@]}"
                sorted_pages="${sorted_pages// /,}"
                local middle_page_value="$(order_and_get_middle_page_of_incorrect_report ${sorted_pages})"
                debug "  Finally sorted. ${pages[@]} / middle = ${middle_page_value}"
                echo "${middle_page_value}"
                return
            fi
        done
    done

    local middle_page_index="$((nb_pages / 2))"
    local middle_page_value="${pages[$middle_page_index]}"
    echo "${middle_page_value}"
)

# Main logic
input_file_name="$(basename ${PUZZLE_INPUT_FILE})"
incorrect_reports_cache_file="${FILE_PATH}/inputs/incorrect_reports_${input_file_name}.cache"
if [[ -f "${incorrect_reports_cache_file}" ]]; then
    debug "Read incorrect reports from cache ${incorrect_reports_cache_file}"
    readarray -t INCORRECT_REPORTS < "${incorrect_reports_cache_file}"
else
    debug "Finding incorrect reports and building cache"
    nb_reports="${#REPORTS[@]}"
    for((i = 0; i < nb_reports; i++)); do
        report="${REPORTS[$i]}"
        check_report_validity "${report}"
        if [[ $? == 1 ]]; then
            INCORRECT_REPORTS+=("${report}")
            echo "${report}" >> "${incorrect_reports_cache_file}"
        fi
    done
fi

nb_reports="${#INCORRECT_REPORTS[@]}"
accumulator=0
declare -a bg_process_pids=()
declare -a tmp_files=()
for((i = 0; i < nb_reports; i++)); do
    debug "Processing incorrect report in background $((i+1))/${nb_reports}"
    report="${INCORRECT_REPORTS[$i]}"
    tmp_file=$(mktemp)
    tmp_files+=(${tmp_file})
    order_and_get_middle_page_of_incorrect_report ${report} > "${tmp_file}" &
    bg_process_pids+=($!)
done

for((i = 0; i < nb_reports; i++)); do
    pid="${bg_process_pids[$i]}"
    debug "Waiting for bg process PID: ${pid}"
    wait ${pid}
    result=$(cat "${tmp_files[$i]}")
    rm "${tmp_files[$i]}"
    ((accumulator+=result))
done

debug "-------------------------"
echo "Sum of middle pages : ${accumulator}"