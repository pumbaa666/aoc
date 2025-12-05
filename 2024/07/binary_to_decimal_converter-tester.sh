#/bin/bash

set -ue

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

function binary_to_decimal() {
    local binary=$1

    decimal=$((2#$binary))
    echo "${decimal}"
}

results_manual=()
results_bash=()
max_length=0
nb_to_test=16
echo "Decimal to binary"
for((i = 0; i < nb_to_test; i++)); do
    _manual="$(decimal_to_binary $i)"
    echo -n "${i} --> "
    len=${#_manual}
    (( len > max_length )) && max_length=$len
    echo ${_manual}
    results_manual+=("${_manual}")

    _bash="$(echo "obase=2; $i" | bc)"
    results_bash+=("${_bash}")

    if [[ "${_manual}" != "${_bash}" ]]; then
        echo "KO, $_manual != $_bash"
    fi
done

echo ""
echo "Binary to decimal"
for((i = 0; i < nb_to_test; i++)); do
    binary="${results_manual[i]}"
    echo -n "${binary} --> "
    binary_to_decimal "${binary}"
done

echo ""
echo "Padded binary :"
printf "%0${max_length}d\n" "${results_manual[@]}"
echo ""