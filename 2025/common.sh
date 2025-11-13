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
