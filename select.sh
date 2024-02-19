

# Function to show columns from metadata file
function show_columns() {
    local tableName=$1
    local metadataFile=".$tableName"
    
    if [ -f "$metadataFile" ]; then
        awk -F ':' '{print NR ":" $1}' "$metadataFile" | tr -d ' ' 
    else
        echo "Metadata file for table $tableName does not exist."
        return 1
    fi
}

# Function to check if the table exists
function table_exists() {
    local tableName=$1
    local dataFile="$tableName"
    if [ -f "$dataFile" ]; then
        return 0
    else
        echo "Table $tableName does not exist."
        return 1
    fi
}
function big_select() {


function organize_result() {
    local tableName=$1
    local result=$2
    local numColumns=$(awk -F ':' 'NR==1 {print NF}' "$tableName")
    
   
    awk -F ':' -v numCols="$numColumns" -v result="$result" 'BEGIN {
        split(result, rows, "\n")
        for (i in rows) {
            split(rows[i], values, ":")
            for (j = 1; j <= numCols; j++) {
                printf "%s", values[j]
                if (j < numCols) printf ""
            }
            printf "\n"
        }
    }' <(echo "$tableName") | sed '/^$/d' | sort -n -t':' -k1,1
}

function execute_select() {
    local tableName=$1
    local selectChoice=$2

    case $selectChoice in
        1)
            awk -F '|' '{print $0}' "$tableName" | sed '/^$/d'
            ;;
        
         2)
            echo "Available columns in table $tableName:"
            show_columns "$tableName"
            
            
            while true; do
                read -p "Enter column numbers to select (e.g., 1,2,3): " userEnteredColumns
                
                
                if [[ $userEnteredColumns =~ ^[0-9,]+$ ]]; then
                    
                    local numColumns=$(awk -F ':' 'NR==1 {print NF}' ".$tableName")
                    local validInput=true

                    
                    IFS=',' read -ra columnNumbers <<< "$userEnteredColumns"
                    for colNum in "${columnNumbers[@]}"; do
                        if ! ((colNum > 0 && colNum <= numColumns)); then
                            echo "Invalid column number: $colNum. Please enter valid column numbers."
                            validInput=false
                            break
                        fi
                    done

                    if [ "$validInput" = true ]; then
                        break
                    fi
                else
                    echo "Invalid input. Please enter valid numbers separated by commas."
                fi
            done
            
            
            result=$(awk -F ':' -v cols="$userEnteredColumns" 'BEGIN {split(cols, arr, ",")} {for (i in arr) printf "%s ", $arr[i]; printf "\n"}' "$tableName" | sort -n -t':' -k1,1)
            organize_result "$tableName" "$result"        
            ;;

        3)
           
    while true; do
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

        read -p "Enter value to match: " matchingValue
        matchingRows=$(awk -F ':' -v col="$columnNumberOption3" -v val="$matchingValue" '$col == val {print $0}' "$tableName")

        if [ -z "$matchingRows" ]; then
            echo "No matching rows found for the given value."
            read -p "Do you want to try again? enter y to try again and enter anythig to go back to the previous menu: " tryAgainOption
            if [ "$tryAgainOption" != "y" ]; then
                return
            fi
        else
            echo "$matchingRows"
            break
        fi
    done
    ;;

        4)
            break
            ;;

        *)
            echo "Invalid option. Please enter numbers between 1 and 4."
            ;;
    esac
}

# select loopp start here 
while true; do
    read -p "Please enter the table name (or 'exit' to quit): " tableName

    if [ "$tableName" == "exit" ]; then
        echo "Exiting the program. Bye!"
        break
    fi

    if table_exists "$tableName"; then
        while true; do
            echo "You are now viewing table $tableName"
            echo "1: SELECT * from $tableName"
            echo "2: Select by column"
            echo "3: Select row where column equals a value"
            echo "4: enter other table name or exit"

            
            while true; do
                read -p "Please select an option by entering a number (1-4): " selectOptionForSelect
                if [[ $selectOptionForSelect =~ ^[1-4]$ ]]; then
                    break
                else
                    echo "Invalid input. Please enter a number between 1 and 4."
                fi
            done

            execute_select "$tableName" "$selectOptionForSelect"
        done
    else
        echo "Please make sure to enter a valid table name."
    fi
done
}
#end of the select***
