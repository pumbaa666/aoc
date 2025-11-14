#!/bin/bash

source "$(dirname "$0")/../common.sh"

INPUT=${1:-example-input.txt}
if [[ ! -f "${INPUT}" ]]; then
    fatal "Input file not found: ${INPUT}"
fi

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
    fatal "Left and right lists have different lengths (${left_len} vs ${right_len})" 2
fi

# Sort both lists
IFS=$'\n' sorted_left=($(sort <<<"${left_list[*]}"))
IFS=$'\n' sorted_right=($(sort <<<"${right_list[*]}"))

# Compare corresponding elements and compute differences
accumulator=0
for ((i = 0; i < left_len; i++)); do
    diff=$((${sorted_left[i]} - ${sorted_right[i]}))
    diff=${diff#-}  # absolute value
    debug "Comparing pair ${i}: ${sorted_left[i]}, ${sorted_right[i]}. Diff = ${diff}"
    ((accumulator+=diff))
done

echo "Final accumulator value: ${accumulator}"