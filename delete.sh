source select.sh
#START OF DELETE FUNCATION..............................................................................................................................................
function big_delete() {
function deleteFUNCTION() {
    local tableName=$1
    local deleteChoice=$2

    case $deleteChoice in
        1)
            echo "Deleting all data from table $tableName"
            > "$tableName"
            ;;
    
       
          2)
             echo "Available columns in table $tableName:"
            show_columns "$tableName"
            
            
            while true; do
                read -p "Enter column number to filter by: " columnNumberOption3
                
                
                if [[ $columnNumberOption3 =~ ^[0-9]+$ ]]; then
                    
                    local totalColumns=$(awk -F ':' 'NR==1 {print NF}' ".$tableName")
                    if ((columnNumberOption3 > 0 && columnNumberOption3 <= totalColumns)); then
                        break
                    else
                        echo "Invalid column number. Please enter a valid column number between 1 and $totalColumns."
                    fi
                else
                    echo "Invalid input. Please enter a valid number."
                fi
            done

            
            while true; do
                read -p "Enter value to match: " matchingValue
                
                
                if awk -F ':' -v col="$columnNumberOption3" -v val="$matchingValue" '$col == val {exit 1}' "$tableName"; then
                    echo "The matching value does not exist."
                    read -p "enter 'yes' return to the previous menu or press anything to try another value: " returnOption
                    if [ "$returnOption" == "yes" ]; then
                        return
                    fi
                else
                    
                    if [ $(awk -F ':' -v col="$columnNumberOption3" -v val="$matchingValue" 'BEGIN {count=0} $col == val {count++} END {print count}' "$tableName") -gt 1 ]; then
                        read -p "The matching value is duplicated. Are you sure you want to delete it? (y)or press anything to try another value " confirmation
                        if [[ $confirmation == 'y' || $confirmation == 'Y' ]]; then
                            break
                        fi
                    else
                        break
                    fi
                fi
            done

            
            awk -F ':' -v col="$columnNumberOption3" -v val="$matchingValue" '$col != val {print $0}' "$tableName" > temp && mv temp "$tableName"
            echo "row deleted succesfully"
            ;;
        3)
            break
            ;;
        *)
            echo "Invalid option. Please enter numbers between 1 and 4."
            ;;
    esac
}




# THE DELETE DML MAIN SECTION ..........................................................
while true; do
    read -p "Please enter the table name (or 'exit' to quit): " tableName

    if [ "$tableName" == "exit" ]; then
        echo "Exiting the program. Bye!"
        break
    fi

    if table_exists "$tableName"; then
        while true; do
            echo "You are now viewing table $tableName"
            echo "1: DELETE all data from $tableName"
          
            echo "2: Delete row where column equals a value"
            echo "3: enter another table name or quit"

            
            while true; do
                read -p "Please select an option by entering a number (1-4): " deleteOption
                if [[ $deleteOption =~ ^[1-4]$ ]]; then
                    break
                else
                    echo "Invalid input. Please enter a number between 1 and 4."
                fi
            done

            deleteFUNCTION "$tableName" "$deleteOption"
        done
    else
        echo "Table $tableName does not exist. Please enter a valid table name."
    fi
done
}
