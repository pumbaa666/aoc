#!/bin/bash

day_num="${1:-}"
[[ -z ${day_num} ]] && echo -e "No day provided" >&2 && exit 1

mkdir -p "${day_num}/inputs"
mkdir -p "${day_num}/results"
touch "${day_num}/puzzle.txt"
touch "${day_num}/inputs/example-input.pt1"
touch "${day_num}/inputs/example-input.pt2"
touch "${day_num}/inputs/real-input.pt1"
touch "${day_num}/inputs/real-input.pt2"
touch "${day_num}/results/example-input.pt1"
touch "${day_num}/results/example-input.pt2"
touch "${day_num}/results/real-input.pt1"
touch "${day_num}/results/real-input.pt2"
cp pt.sh "${day_num}/pt1.sh"
cp pt.sh "${day_num}/pt2.sh"
chmod +x "${day_num}/pt1.sh"
chmod +x "${day_num}/pt2.sh"
