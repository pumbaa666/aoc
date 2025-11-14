#!/bin/bash

input_types=("example-input" "real-input")
for day in $(find . -mindepth 1 -maxdepth 1 -type d | sort); do
    echo "Day ${day}"
    for((part = 1; part <= 2; part++)); do
        echo -n "  Part ${part}"

        for input_type in ${input_types[@]}; do
            echo -n " / ${input_type}"
            result=$(bash "${day}/pt${part}.sh" "${day}/inputs/${input_type}.pt${part}")
            expected_result=$(cat "${day}/results/${input_type}-result.pt${part}")

            [[ "${result}" != "${expected_result}" ]] && echo -n " ❌" || echo -n " ✅"
        done
        echo ""
    done
    echo ""
done