#!/bin/bash

set -uo pipefail

DEBUG=${DEBUG:-"false"}
FILE_ABS_PATH="$(realpath ${BASH_SOURCE[1]})" # Absolute file name of the script sourcing me (common.sh)
FILE_PATH=${FILE_ABS_PATH%/*}                 # Absolute path
FILE_NAME=${FILE_ABS_PATH##*/}                # File name (with extention)
FILE_EXT=${FILE_NAME##*.}                     # File extention
FILE_PREFIX=${FILE_NAME%.*}                   # File name (without extention)

function debug() {
    [[ "${DEBUG}" == "true" ]] && echo -e "[DEBUG] ${@}" >&2
}

function fatal() {
    local error_code=1
    [[ $# == 0 ]] && exit ${error_code}
    
    local args=( "$@" )
    
    # if the last parameter is a 8 bit number, set the value to error_code and don't print it
    local last_elem=${args[-1]}
    if [[ ${last_elem} =~ [0-9]+ && ${last_elem} -gt 0 && ${last_elem} -lt 256 ]]; then
        error_code=${last_elem}
        unset args[-1]
    fi
    echo -e "[FATAL] ${args[@]}" >&2
    exit ${error_code}
}

function print_array() { 
    local key value name;
    for name in "$@";
    do
        echo "${name}";
        echo "(";
        eval "for key in \"\${!${name}[@]}\"; do
                value=\"\${${name}[\$key]}\"
                echo \"  [\$key] => \\\"\$value\\\"\"
              done";
        echo ")";
    done
}

# File input (puzzle)
PUZZLE_INPUT_FILE=${1:-inputs/example-input.$FILE_PREFIX}
if [[ ! -f "${PUZZLE_INPUT_FILE}" ]]; then
    fatal "Input file not found: ${PUZZLE_INPUT_FILE}" 1
fi
