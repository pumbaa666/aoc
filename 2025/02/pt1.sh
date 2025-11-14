source "$(dirname "$0")/../common.sh"

INPUT=${1:-example-input.txt}
if [[ ! -f "${INPUT}" ]]; then
    echo "Input file not found: ${INPUT}"
    exit 1
fi

# Read input data into REPORTS array
REPORTS=()
while IFS= read -r line; do
    read -r report <<< ${line}
    REPORTS+=("$report")
done < "${INPUT}"

nb_reports=${#REPORTS[@]}
for ((i = 0; i < nb_reports; i++)); do
    report=${REPORTS[i]}
    echo "Repport $i : $report"
done