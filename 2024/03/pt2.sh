#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Check if puzzle input contains safe string
# (we'll be replacing all "don't" with the safe string for easier regex matching)
SAFE_STRING="|"
cat "${PUZZLE_INPUT_FILE}" | grep ${SAFE_STRING}
[[ $# != 0 ]] && fatal "Puzzle input contains SAFE_STRING '${SAFE_STRING}'" 10

# Read input data into one line (INSTRUCTIONS)
INSTRUCTIONS=""
while IFS= read -r line; do
    line=$(sed -r "s/don't()/|/g" <<< ${line})
    INSTRUCTIONS="${INSTRUCTIONS}${line}"
done < "${PUZZLE_INPUT_FILE}"
INSTRUCTIONS="do()${INSTRUCTIONS}${SAFE_STRING}"
debug "Full INSTRUCTIONS : $INSTRUCTIONS"

# Valid input example : do() ... don't()
do_regex="do\(\)([^${SAFE_STRING}]+)${SAFE_STRING}"
i=0
while [[ ${INSTRUCTIONS} =~ ${do_regex} ]]; do
    # debug "Valids instructions : ${BASH_REMATCH[1]}"
    match=${BASH_REMATCH[0]}
    instruction=${BASH_REMATCH[1]}
    debug " - Valid : ${instruction}"
    INSTRUCTIONS=${INSTRUCTIONS/"${match}"/} # Remove current match from INSTRUCTIONS and try again
    ((i++))
    if ((i > 4)); then
        exit 99
    fi
done

# mul_regex="mul\(([0-9]{1,3}),([0-9]{1,3})\)"
# accumulator=0
# while [[ ${INSTRUCTIONS} =~ ${mul_regex} ]]; do
#     match=${BASH_REMATCH[0]}
#     lhs=${BASH_REMATCH[1]}
#     rhs=${BASH_REMATCH[2]}
#     debug "Match: ${match} / ${lhs} * ${rhs}"

#     result=$((lhs * rhs))
#     ((accumulator+=result))

#     INSTRUCTIONS=${INSTRUCTIONS/"${match}"/} # Remove current match from INSTRUCTIONS and try again
# done

# debug "-------------------------"
# echo "Total : ${accumulator}"