#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data into separate arrays (left and right)
left_list=()
right_list=()
while IFS= read -r line; do
    read -r left right <<< ${line}
    left_list+=("$left")
    right_list+=("$right")
done < "${INPUT}"

# Check that both lists have the same length
left_len=${#left_list[@]}
right_len=${#right_list[@]}
if [[ ${left_len} -ne ${right_len} ]]; then
    echo "Error: Left and right lists have different lengths (${left_len} vs ${right_len})"
    exit 2
fi

# Count the number of occurence of $1 in right_list
function count_num() {
    local num=$1

    local nb_occurence=0
    local i
    for ((i = 0; i < left_len; i++)); do
        right=${right_list[i]}
        if ((num == right)); then
            ((nb_occurence++))
        fi
    done

    echo ${nb_occurence}
}

# Compare corresponding elements and compute differences
accumulator=0
declare -A cache
for ((i = 0; i < left_len; i++)); do
    ((i % 100 == 0)) && debug "Processing element ${i} / ${left_len}"
    left_num=${left_list[i]}

    # Check in cache first
    cached_value=${cache[${left_num}]-}
    if [[ -n ${cached_value} ]]; then
        debug "found in cache : ${cache[${left_num}]}" >&2
        nb_occurence=${cache[${left_num}]}
    else
        nb_occurence=$(count_num ${left_num})
        cache[${left_num}]=${nb_occurence} # Cache it
        debug "Storing ${nb_occurence} into cache[${left_num}] : ${cache[${left_num}]}" >&2
    fi
    
    ((accumulator+=${left_num}*${nb_occurence}))
done

echo "Final accumulator value: ${accumulator}"