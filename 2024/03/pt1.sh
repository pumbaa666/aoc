#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data into one line (INSTRUCTIONS)
INSTRUCTIONS=""
while IFS= read -r line; do
    INSTRUCTIONS="${INSTRUCTIONS}${line}"
done < "${INPUT}"

# Valid input example : mul(X,Y) # X and Y can be 3 digits max
mul_regex="mul\(([0-9]{1,3}),([0-9]{1,3})\)"
accumulator=0
while [[ ${INSTRUCTIONS} =~ ${mul_regex} ]]; do
    match=${BASH_REMATCH[0]}
    lhs=${BASH_REMATCH[1]}
    rhs=${BASH_REMATCH[2]}
    debug "Match: ${match} / ${lhs} * ${rhs}"

    result=$((lhs * rhs))
    ((accumulator+=result))

    INSTRUCTIONS=${INSTRUCTIONS/"${match}"/} # Remove current match from INSTRUCTIONS and try again
done

debug "-------------------------"
echo "Total : ${accumulator}"