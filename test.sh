foo() {
    local lines=$(ls -l)

    local IFS=$'\n'

    echo $SHELL
    echo "test out"
    if [[ $SHELL = *"zsh"* ]]; then
        for line in ${=lines}; do
            echo line: $line
        done
    else 
        for line in $lines; do
            echo line: $line
        done
    fi

}

foo
