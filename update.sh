source select.sh
source update2.sh
function big_update() {

function update_row() {
    local tableName=$1
    local totalColumns=$(awk -F ':' 'NR==1 {print NF}' "$tableName")
    echo "Available columns in table $tableName:"
    show_columns "$tableName"
    declare -a newValues

  
  
  #start of data type condation 
  for ((i=1; i<=totalColumns; i++)); do
    local metadataFile=".$tableName"
    local columnName=$(awk -F ':' -v col="$i" 'NR==col {print $1}' "$metadataFile")
    local dataType=$(awk -F ':' -v col="$i" 'NR==col {print $2}' "$metadataFile")

    while true; do
        IFS= read -r -p "Enter new value for column $i ($columnName): " newValue

        if [ "$dataType" == "string" ]; then
            if [ -n "$newValue" ]; then
                local isDuplicate=$(awk -F ':' -v col="$i" -v val="$newValue" '$col == val {print $0}' "$tableName")
                if [ -z "$isDuplicate" ]; then
                    newValues[$i]="$newValue"
                    break
                else
                    echo "Duplicate value for column $i. Please enter a unique value."
                fi
            else
                echo "Invalid input. Please enter a non-null value for the string column."
            fi
        elif [ "$dataType" == "int" ]; then
            if [[ "$newValue" =~ ^[0-9]+$ ]]; then
                local isDuplicate=$(awk -F ':' -v col="$i" -v val="$newValue" '$col == val {print $0}' "$tableName")
                if [ -z "$isDuplicate" ]; then
                    newValues[$i]="$newValue"
                    break
                else
                    echo "Duplicate value for column $i. Please enter a unique value."
                fi
            else
                echo "Invalid input. Please enter a valid integer."
            fi
        else
            newValues[$i]="$newValue"
            break
        fi
    done
done






    while true; do
        echo "Available columns in table $tableName:"
        show_columns "$tableName"
        IFS= read -r -p "Enter column number to match: " matchColumnNumber

        if [[ $matchColumnNumber =~ ^[0-9]+$ ]] && ((matchColumnNumber > 0 && matchColumnNumber <= totalColumns)); then
            break
        else
            echo "Invalid input. Please enter a valid column number between 1 and $totalColumns."
        fi
    done

    while true; do
        IFS= read -r -p "Enter value to match: " matchingValue

        local isMatchingValue=$(awk -F ':' -v col="$matchColumnNumber" -v val="$matchingValue" '$col == val {print $0}' "$tableName")

        if [ -n "$isMatchingValue" ]; then
            local isUnique=$(awk -F ':' -v col="$matchColumnNumber" -v val="$matchingValue" '$col == val {print $0}' "$tableName" | wc -l)

            if [ "$isUnique" -eq 1 ]; then
                break
            else
                echo "Error: The matching value is duplicated. Please enter a different value."
            fi
        else
            echo "Error: The matching value does not exist. Please enter a valid value."

            read -p "Do you want to try again? Enter 'y' to try again, or enter anything else to go back to the previous menu: " tryAgainOption

            if [ "$tryAgainOption" != "y" ]; then
                return
            fi
        fi
    done
#l print fincationnnns
 
    joinedValues=$(IFS='|'; echo "${newValues[*]}")

   
    joinedValuesWithoutSpaces=$(echo "$joinedValues" | sed 's/^\( *\)/###SPACE###\1/' | sed 's/\( *\)$$/\1###SPACE###/')

    awk -F ':' -v newVals="$joinedValuesWithoutSpaces" -v colToMatch="$matchColumnNumber" -v matchVal="$matchingValue" '
    BEGIN { OFS = FS; }
    $colToMatch == matchVal { 
        gsub(/###SPACE###/, " ", newVals); 
        split(newVals, arr, "|")
        for (i=1; i<=NF; i++) {
            $i = arr[i]
        }
        sub(/^ /, "", $0); #to remove spacesss
    }
    { print $0 }
    ' "$tableName" > temp_file && mv temp_file "$tableName"

    echo "Row updated successfully."
}

#update main programe
function execute_select_update() {
    local tableName=$1
    local selectChoiceUPDATE=$2

    case $selectChoiceUPDATE in
        1)
            update_record "$tableName"
            ;;
        2)
            update_row "$tableName"
            ;;
            
            3)
          
            break
            ;;
        *)
            echo "Invalid option. Please enter numbers between 1 and 2."
            ;;
    esac
}

# Main program loop
while true; do
    read -p "Please enter the table name (or 'exit' to quit): " tableName

    if [ "$tableName" == "exit" ]; then
        echo "Exiting the program. Bye!"
        break
    fi

    if table_exists "$tableName"; then
        while true; do
            echo "You are now viewing table $tableName"
            
            echo "1: Update a single record"
            echo "2: Update the entire row"
             echo "3: enter other table name or exit "
            

            
            while true; do
                read -p "Please select an option by entering a number (1:3 ): " selectOptionUPDATE
                if [[ $selectOptionUPDATE =~ ^[123]$ ]]; then
                    break
                else
                    echo "Invalid input. Please enter 1 or 2 or 3."
                fi
            done

            execute_select_update "$tableName" "$selectOptionUPDATE"
        done
    else
        echo "Please make sure to enter a valid name."
    fi
done
}
