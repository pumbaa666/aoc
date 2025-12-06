#!/bin/bash

source "$(dirname "$0")/../common.sh"

# Read input data
lines1=()
lines2=()
lines3=()
lines4=()
operators=()

tmp_lines=()
nb_lines="$(wc -l ${PUZZLE_INPUT_FILE})"
nb_lines="${nb_lines/ */}"
line_num=1
while IFS= read -r line; do
    IFS=' ' read -ra tmp_lines <<< ${line}
    nb_num="${#tmp_lines[@]}"
    for((i = 0; i < nb_num; i++)); do
        num="${tmp_lines[i]}"
        case "${line_num}" in
            ${nb_lines}) operators+=("${num}");;
            '1') lines1+=("${num}");;
            '2') lines2+=("${num}");;
            '3') lines3+=("${num}");;
            '4') lines4+=("${num}");;
        esac
    done
    ((line_num++))
done < "${PUZZLE_INPUT_FILE}"

# Main logic
accumulator=0
for((i = 0; i < nb_num; i++)); do
    operator="${operators[i]}"
    num1="${lines1[i]}"
    num2="${lines2[i]}"
    num3="${lines3[i]}"
    num4="${lines4[i]:-}"
    debug "[$i] Processing $num1 $operator $num2 $operator $num3 $operator $num4"
    case "${operator}" in
        '+') [[ -z "${num4}" ]] && num4=0 # A bit ugly, but what you gonna do ??
            tmp_result=$((num1 + num2 + num3 + num4))
            ;;

        '*') [[ -z "${num4}" ]] && num4=1
            tmp_result=$((num1 * num2 * num3 * num4))
            ;;

        *)   fatal "Unrecognized operator : '${operator}'" 2;;
    esac
    ((accumulator += tmp_result))
    debug "     = ${tmp_result} / accu = ${accumulator}"
done

debug "-------------------------"
echo "Grand total is : ${accumulator}"