#!/bin/bash

source "$(dirname "$0")/../common.sh"

INPUT=${1:-example-input.txt}
if [[ ! -f "${INPUT}" ]]; then
    fatal "Input file not found: ${INPUT}"
fi

# Read input data into one line (INSTRUCTIONS)
INSTRUCTIONS=""
while IFS= read -r line; do
    INSTRUCTIONS="${INSTRUCTIONS}${line}"
done < "${INPUT}"
INSTRUCTIONS="do()${INSTRUCTIONS}don't()"
debug "Full INSTRUCTIONS : $INSTRUCTIONS"

# Valid input example : do() ... don't()
do_regex="do\(\)(.*)don't\(\)"
while [[ ${INSTRUCTIONS} =~ ${do_regex} ]]; do
    # debug "Valids instructions : ${BASH_REMATCH[1]}"
    match=${BASH_REMATCH[0]}
    instruction=${BASH_REMATCH[1]}
    debug " - Valid : ${instruction}"
    INSTRUCTIONS=${INSTRUCTIONS/"${match}"/} # Remove current match from INSTRUCTIONS and try again
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