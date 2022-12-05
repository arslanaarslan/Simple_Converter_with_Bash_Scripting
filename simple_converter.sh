#!/usr/bin/bash

file_name="definitions.txt"

if [ ! -e  $file_name ]; then
    touch $file_name
fi

function convertUnits() {
    if [ ! -s $file_name ];
    then
        echo "Please add a definition first!"
        return
    fi

    echo "Type the line number to convert units or '0' to return"

    line_count=$((`wc -l < $file_name`))

    n=1
    while read line; do
        #read each line
        echo "$n. $line"
        n=$((n+1))
    done < $file_name

    while true;
    do
        read -a user_input

        number_input=${user_input[@]}

        if [[ -z $number_input ]]; then
            echo "Enter a valid line number!"
            continue;
        fi

        line_number=$(($number_input))

        if [[ $line_number -eq 0 ]]; then
            break;
        fi

        if [ $line_number -gt $line_count -o $line_number -lt 0 ]; then
            echo "Enter a valid line number!"
            continue;
        fi

        line=$(sed "${line_number}!d" "$file_name")
        read -a text <<< "$line"

        constant=${text[1]}
        # echo "constant: $constant"

        echo "Enter a value to convert:"

        while true
        do
            read -a user_input

            value=${user_input[@]}

            if [[ -z $value || $value =~ ^[a-zA-Z\s]*$ ]]; then
                echo "Enter a float or integer value!"
                continue;
            fi

            # echo "value: $value"
            # echo "constant: $constant"
            result=$(echo $value*$constant | bc)

            echo "Result: $result"

            break;
        done

        break;
    done
}

function addDefinition() {
    completed=false

    while ! [[ $completed == true ]]; do
        echo "Enter a definition:"

        read -a user_input

        string="${user_input[@]}"
        definition="${user_input[0]}"
        constant="${user_input[1]}"

        regex1='^[A-Za-z]+_to_[A-Za-z]+\s-?[0-9]+\.?[0-9]*$'

        if [[ "$string" =~ $regex1 ]]; then
            # to add a line
            line=$string
            echo "$line" >> "$file_name"
            completed=true
        else
            echo "The definition is incorrect!"
        fi
    done
}

function removeDefinition() {
    if [ ! -s $file_name ];
    then
        echo "Please add a definition first!"
        return
    fi

    echo "Type the line number to delete or '0' to return"

    n=1
    while read line; do
        #read each line
        echo "$n. $line"
        n=$((n+1))
    done < $file_name

    line_count=$((`wc -l < $file_name`))

    while true; do
        read -a user_input

        number_input=${user_input[@]}

        if [[ -z $number_input ]]; then
            echo "Enter a valid line number!"
            continue;
        fi

        line_number=$(($number_input))

        if [[ $line_number -eq 0 ]]; then
            break;
        fi

        if [ $line_number -gt $line_count -o $line_number -lt 0 ]; then
            echo "Enter a valid line number!"
            continue;
        fi

        sed -in "${line_number}d" $file_name
        break;
    done
}


echo "Welcome to the Simple converter!"

while true
do
    echo -e "\nSelect an option"
    echo "0. Type '0' or 'quit' to end program"
    echo "1. Convert units"
    echo "2. Add a definition"
    echo "3. Delete a definition"

    read -a user_input

    answer="${user_input[@]}"

    case "$answer" in
        "0" | "quit")
            echo "Goodbye!"
            break
            ;;
        "1")
            convertUnits;;
        "2")
            addDefinition;;
        "3")
            removeDefinition;;
        *)
            echo "Invalid option!"
            ;;
        esac
done