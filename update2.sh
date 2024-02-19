function update_record() {
    local tableName=$1

    
    local totalColumns=$(awk -F ':' 'NR==1 {print NF}' "$tableName")

    echo "Available columns in table $tableName:"
    show_columns "$tableName"

    
    while true; do
        read -p "Enter column number to update: " updateColumnNumber

        
        if [[ $updateColumnNumber =~ ^[0-9]+$ ]] && ((updateColumnNumber > 0 && updateColumnNumber <= totalColumns)); then
            break
        else
            echo "Invalid input. Please enter a valid column number between 1 and $totalColumns."
        fi
    done

    
    local metadataFile=".$tableName"
    local columnName=$(awk -F ':' -v col="$updateColumnNumber" 'NR==col {print $1}' "$metadataFile")
    local dataType=$(awk -F ':' -v col="$updateColumnNumber" 'NR==col {print $2}' "$metadataFile")
    local isPrimaryKey=$(awk -F ':' -v colName="$columnName" '$1 == colName && /pk/ {print $0}' "$metadataFile")

    


while true; do
    read -p "Enter new value for the selected column: " newValue

    if [ "$dataType" == "string" ]; then
        if [ -n "$newValue" ]; then
            if [ -n "$isPrimaryKey" ]; then
                local isUnique=$(awk -F ':' -v col="$updateColumnNumber" -v val="$newValue" 'tolower($col) == tolower(val) {print $0}' "$tableName" | wc -l)
                if [ "$isUnique" -eq 0 ]; then
                    break
                else
                    echo "Error: The string value is duplicated. Please enter a different value."
                fi
            else
                break
            fi
        else
            echo "Invalid input. Please enter a non-null value for the string column."
        fi
    elif [ "$dataType" == "int" ]; then
        if [[ "$newValue" =~ ^[0-9]+$ ]]; then
            if [ -n "$isPrimaryKey" ]; then
                local isUnique=$(awk -F ':' -v col="$updateColumnNumber" -v val="$newValue" '$col == val {print $0}' "$tableName" | wc -l)
                if [ "$isUnique" -eq 0 ]; then
                    break
                else
                    echo "Error: The integer value is duplicated. Please enter a different value."
                fi
            else
                break
            fi
        else
            echo "Invalid input. Please enter a valid integer."
        fi
    else
        break
    fi
done


    
    while true; do
        echo "Available columns in table $tableName:"
        show_columns "$tableName"

        read -p "Enter column number to match: " matchColumnNumber

        
        if [[ $matchColumnNumber =~ ^[0-9]+$ ]] && ((matchColumnNumber > 0 && matchColumnNumber <= totalColumns)); then
            break
        else
            echo "Invalid input. Please enter a valid column number between 1 and $totalColumns."
        fi
    done

    
    while true; do
        read -p "Enter value to match: " matchingValue

        
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

    # Update the matching row
    awk -F ':' -v colToUpdate="$updateColumnNumber" -v newVal="$newValue" -v colToMatch="$matchColumnNumber" -v matchVal="$matchingValue" '
        BEGIN { OFS = FS }
        $colToMatch == matchVal { $colToUpdate = newVal }
        { print $0 }
    ' "$tableName" > temp_file && mv temp_file "$tableName"

    echo "Row updated successfully."
}
