#!/bin/sh

# Inspirations :
# https://stackoverflow.com/questions/33294986/splitting-large-text-file-on-every-blank-line
# https://stackoverflow.com/questions/2702564/how-can-i-quickly-sum-all-numbers-in-a-file
# https://stackoverflow.com/questions/47087154/bash-getting-max-value-from-a-list-of-integers
# https://www.oreilly.com/library/view/bash-cookbook/0596526784/ch07s13.html

# Get filename from argument or set default
FILENAME=${1:-data.txt}
ELFE_FOLDER="./.elfes"
mkdir -p $ELFE_FOLDER

# Split file on empty lines
splitFileOnEmptyLines() {
    awk -v RS= -v PATTERN="$ELFE_FOLDER/elfe%d.cal" '{FILE=sprintf(PATTERN, NR); print > FILE}' $1
}

readFileAndSum() {
    awk '{ sum += $1 } END { print sum }' $1
}

printFilesInFolder() {
    for file in $ELFE_FOLDER/*; do
        readFileAndSum $file
    done
}

splitFileOnEmptyLines $FILENAME
printFilesInFolder | sort -n | tail -n 1 # First star
printFilesInFolder | sort -n | tail -n 3 | awk '{ sum += $1 } END { print sum }' # Second star