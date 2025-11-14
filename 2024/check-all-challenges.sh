#!/bin/bash

input_types=("example-input" "real-input") #"real-input"
for day in $(find . -mindepth 1 -maxdepth 1 -type d | sort); do
    echo "Day ${day}"
    for((part = 1; part <= 2; part++)); do
        echo -n "  Part ${part}"

        for input_type in ${input_types[@]}; do
            echo -n " / ${input_type}"
            result=$(bash "${day}/pt${part}.sh" "${day}/${input_type}.txt")
            expected_result=$(cat "${day}/${input_type}.pt${part}")

            if [[ "${result}" != "${expected_result}" ]]; then
                # echo " ❌"
                echo -n " ❌"
            else
                # echo " ✅"
                echo -n " ✅"
            fi

        done
        echo ""
    done

    echo ""
done