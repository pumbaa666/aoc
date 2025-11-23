#!/bin/bash

source "$(dirname "$0")/../common.sh"

VALID_OPERATORS=( "+" "*" )

# Read input data
declare -A EQUATIONS_INPUT
while IFS= read -r line; do
    IFS=':' read -r result equation <<< ${line}
    EQUATIONS_INPUT[$result]="${equation}"
done < "${PUZZLE_INPUT_FILE}"

function decimal_to_binary() {
    local decimal=$1

    local int_part=$((decimal / 2))
    local modulo=$((decimal % 2))
    local result="${modulo}"

    while (( int_part > 0 )); do
        modulo=$((int_part % 2))
        int_part=$((int_part / 2))
        result="${modulo}${result}"
    done
    echo "${result}"
}

function solve_equation() {
    local equation=$1
    local expected_result=$2
    local result=$(echo "${equation}" | bc)
    if [[ "${result}" == "${expected_result}" ]]; then
        # echo "${expected_result}"
        return 0
    fi

    # echo "0"
    return 1
}

# TODO First, generate the equation
# then solve them in parallel
function generate_equations() {
    local result=$1
    local equation_str="$2"
    
    # Un-stringify equation
    local equation
    read -ra equation <<< "${equation_str}"
    local nb_terms="${#equation[@]}"

    # Count in binary to get all operator permutations
    # TODO do that only once and cache the result
    local nb_operator_permutation=$(( 2 ** (nb_terms - 1) ))
    local operator_permutations=()
    local longest_binary=0
    local i len binary
    for ((i = 0; i < nb_operator_permutation; i++)); do
        binary="$(decimal_to_binary $i)"
        len=${#binary}
        (( len > longest_binary )) && longest_binary=$len
        operator_permutations+=("${binary}")
    done

    # Add as much parenthesis as the is of terms -1
    # since we have to badly solve the equations, from left to right, without regarding to precedence rules
    local starting_parenthesis=""
    local p
    for ((p = 0; p < nb_terms - 1; p++)); do
        starting_parenthesis="${starting_parenthesis}("
    done

    # Loop through all binary result, padded with zeros to the left
    local i op previous_term current_term
    for binary in $(printf "%0${longest_binary}d\n" "${operator_permutations[@]}"); do
        previous_term=${equation[0]}
        equation_str="${starting_parenthesis}${previous_term}"
        for ((i = 1; i < nb_terms; i++)); do
            op="${binary:((i-1)):1}"
            case "${op}" in
                0) op="+";;
                1) op="*";;
            esac
            current_term=${equation[$i]}
            equation_str="${equation_str} ${op} ${current_term})"
        done

        local tmp_res=$(echo "${equation_str}" | bc)
        debug "Solving : ${result} = ${equation_str} = ${tmp_res} : "
        
        # if $(solve_equation "${equation_str}" "${result}") ; then
        if [[ "${tmp_res}" == "${result}" ]]; then
            debug "  yep"
            echo "${result}"
            return 0
        fi
        debug "nope"
    done

    echo "0" # TODO required ?
    return 1
}

# Main logic
accumulator=0
i=0
nb_eq=${#EQUATIONS_INPUT[@]}
for result in ${!EQUATIONS_INPUT[@]}; do
    ((i++))
    echo "Solving eq $i / $nb_eq"
    equation="${EQUATIONS_INPUT[$result]}"
    debug
    debug "${result} = ${equation}"
    result=$(generate_equations "${result}" "${equation}")
    ((accumulator+=result))
done

debug "-------------------------"
echo "Sum of valid equations : ${accumulator}"