#!/bin/bash

source "$(dirname "$0")/../common.sh"

nb_lines="$(wc -l ${PUZZLE_INPUT_FILE})"
nb_lines="${nb_lines/ */}"

# Read the operators first, to know the size of each block
line_num=0
index=0
blocks=()
operators=()
while IFS= read -r line; do
    # Ignore the numbers, skip to operators
    ((line_num++))
    ((${line_num} < nb_lines)) && continue

    # Get size of each block based on operator positions
    debug "Reading operators : $line"
    line_size="${#line}"
    block_start=0
    block_end=
    char="${line:0:1}"
    operators+=("${char}")
    for((i = 1; i < line_size; i++)); do
        char="${line:i:1}"
        [[ "${char}" == ' ' ]] && continue

        operators+=("${char}")
        block_end="$((i-2))" # Don't count the current operator index. Also don't count the previous space
        block="${block_start},${block_end}"
        blocks+=( "${block}" )
        block_start="${i}"
    done

    # Do the last one since we didn't hit an operator before the end of the line    
    block_end="$((i-1))"
    block="${block_start},${block_end}"
    blocks+=( "${block}" )
done < "${PUZZLE_INPUT_FILE}"

# Now we read all the numbers, ignoring the last operators line
tmp_lines=()
lines=()
line_num=0
while IFS= read -r line; do
    ((line_num++))
    (($line_num >= nb_lines)) && break;
    lines+=( "${line}" )
done < "${PUZZLE_INPUT_FILE}"

# Main logic
function solve_block() {
    local operator="$1"
    local block_width="$2"
    shift 2
    local nums=("$@")
    local block_height="${#nums[@]}"

    debug "Solving '${operator}' : ${nums[@]}. block_width = ${block_width} / block_height = ${block_height}"

    local reconstructed_nums=()
    local x y num reconstructed_num char
    # Walks through each digit
    for((x = 0; x < block_width; x++)); do
        reconstructed_num=""
        # Walks through each num, extracting the corresponding digit
        for((y = 0; y < block_height; y++)); do
            num="${nums[y]}"
            char="${num:$x:1}"
            [[ -z "${char}" ]] && continue
            reconstructed_num="${reconstructed_num}${char}"
        done
        debug "reconstructed_num : ${reconstructed_num}"
        reconstructed_nums+=( "${reconstructed_num}" )
    done

    # Do the math on the reconstructed numbers
    local nb_nums="${#reconstructed_nums[@]}"
    local i
    case "${operator}" in
        '+') local result=0
            for((i = 0; i < nb_nums; i++)); do
                num="${reconstructed_nums[i]}"
                ((result += num))
            done
            ;;

        '*') local result=1
            for((i = 0; i < nb_nums; i++)); do
                num="${reconstructed_nums[i]}"
                ((result *= num))
            done
            ;;

        *)   fatal "Unrecognized operator : '${operator}'" 2;;
    esac
    echo "${result}"
}

accumulator=0
nb_blocks="${#operators[@]}"
for((i = 0; i < nb_blocks; i++)); do
    operator="${operators[i]}"
    IFS=',' read -r block_start block_end <<< "${blocks[i]}"
    debug "Operator ${i} : '$operator' [${block_start},${block_end}]"
    block_width=$((block_end - block_start + 1))

    nums=()
    for((j = 0; j < nb_lines - 1; j++)); do # -1 --> ignore last operators line
        line="${lines[j]}"
        num="${line:block_start:block_width}"
        nums+=( "${num}" )
    done

    tmp_result=$(solve_block "${operator}" "${block_width}" "${nums[@]}")

    ((accumulator += tmp_result))
done

debug "-------------------------"
echo "Grand total is : ${accumulator}"