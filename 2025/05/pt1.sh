#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data
fresh_ranges=()
ingredients=()
type="r" # r: ranges / i: ingredients
while IFS= read -r line; do
    [[ -z "${line}" ]] && type="i" && continue

    case "${type}" in
        r) fresh_ranges+=( ${line} ) ;;
        i) ingredients+=( ${line} ) ;;
    esac
done < "${PUZZLE_INPUT_FILE}"

nb_ranges="${#fresh_ranges[@]}"
nb_ingredients="${#ingredients[@]}"
debug "Found ${nb_ranges} ranges and ${nb_ingredients} ingredients"

# Main logic
function in_range() {
    local ingredient=$1
    local range=$2

    local range_start range_end
    IFS='-' read -r range_start range_end <<< "${range}"
    debug "Check if '${ingredient}' is between [${range_start} - ${range_end}]"
    if ((ingredient >= range_start && ingredient <= range_end)); then
        return 0
    else
        return 1
    fi
}

fresh_ingredients=0
for((i = 0; i < nb_ingredients; i++)); do
    ingredient="${ingredients[i]}"
    for((j = 0; j < nb_ranges; j++)); do
        range="${fresh_ranges[j]}"
        in_range "${ingredient}" "${range}" && ((fresh_ingredients++)) && break
    done
done

debug "-------------------------"
echo "Total : ${fresh_ingredients}"