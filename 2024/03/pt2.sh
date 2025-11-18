#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Check if puzzle input contains replacement strings
# (we'll be replacing all "do()" and "don't" with safe strings for easier regex matching)
DO_REPLACEMENT="è"
DONT_REPLACEMENT="ç"
cat "${PUZZLE_INPUT_FILE}" | grep -q "${DONT_REPLACEMENT}"
[[ $? == 0 ]] && fatal "Puzzle input contains DONT_REPLACEMENT '${DONT_REPLACEMENT}'" 10
cat "${PUZZLE_INPUT_FILE}" | grep -q "${DO_REPLACEMENT}"
[[ $? == 0 ]] && fatal "Puzzle input contains DO_REPLACEMENT '${DO_REPLACEMENT}'" 10

# Read input data into one line (instructions_str)
# Replace "do()" with $DO_REPLACEMENT and "don't()" with $DONT_REPLACEMENT
instructions_str=""
while IFS= read -r line; do
    line=$(sed -r "s/do\(\)/${DO_REPLACEMENT}/g" <<< ${line})
    line=$(sed -r "s/don't\(\)/${DONT_REPLACEMENT}/g" <<< ${line})
    instructions_str="${instructions_str}${line}"
done < "${PUZZLE_INPUT_FILE}"
instructions_str="${DO_REPLACEMENT}${instructions_str}${DONT_REPLACEMENT}"
debug "Full instructions_str : $instructions_str\n"

# Find instructions to process and populate an array with them
# Valid input example : do() ... mul(XXX,YYY) ... don't()
do_regex="${DO_REPLACEMENT}([^${DONT_REPLACEMENT}]+)${DONT_REPLACEMENT}"
instructions_array=()
while [[ ${instructions_str} =~ ${do_regex} ]]; do
    match="${BASH_REMATCH[0]}"
    instruction="${BASH_REMATCH[1]}"
    debug " - Process : instr = ${instruction} / match = '${match}'"
    [[ -z "${match}" ]] && debug "No more matches" && break;
    instructions_array+=("${instruction}")
    instructions_str=${instructions_str/"${DO_REPLACEMENT}${instruction}${DONT_REPLACEMENT}"/} # Remove current match from instructions_str and try again
done

# Process all instructions from array
nb_instructions=${#instructions_array}
debug
debug "Found ${nb_instructions} instructions to process"

mul_regex="mul\(([0-9]{1,3}),([0-9]{1,3})\)"
accumulator=0
for((i = 0; i < ${nb_instructions}; i++)); do
    instructions_str="${instructions_array[$i]:-}"
    while [[ ${instructions_str} =~ ${mul_regex} ]]; do
        match=${BASH_REMATCH[0]}
        lhs=${BASH_REMATCH[1]}
        rhs=${BASH_REMATCH[2]}
        debug "Match: ${match} / ${lhs} * ${rhs}"

        result=$((lhs * rhs))
        ((accumulator+=result))

        instructions_str=${instructions_str/"${match}"/} # Remove current match from instructions_str and try again
    done
done

debug "-------------------------"
echo "Total : ${accumulator}"