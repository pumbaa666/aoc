#!/bin/bash

day_min="${1:-01}"
day_max="${2:-31}"

input_types=("example-input" "real-input")
for day in $(find . -mindepth 1 -maxdepth 1 -type d | sort); do
    day_str=$(realpath --relative-to="." ${day})

    # Skip irrelevant days
    [[ "$day_str" < "$day_min" || "$day_str" > "$day_max" ]] && continue

    echo "Day ${day_str}"
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