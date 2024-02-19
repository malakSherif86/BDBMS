
insert_data() {
while true; do
read -p "Enter table name: " tableName

        filePath="./${tableName}"
        metadataFile="./.${tableName}"

        if [[ -z "$tableName" || ! "$tableName" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            echo "Invalid table name. Table name must start with a letter and can only contain letters, numbers, and underscores. Try again."
            continue
        fi

        if [ -e "$filePath" ]; then
            echo "File found. Please insert data."

            if [ -e "$metadataFile" ]; then
                columns=()
                pkColumn=""
                pkType=""
                while IFS=':' read -r columnName dataType rest; do
                    columns+=("$columnName:$dataType")
                    if [[ "$rest" == "pk" ]]; then
                        pkColumn="$columnName"
                        pkType="$dataType"
                    fi
                done < "$metadataFile"

                if [ -n "$pkColumn" ]; then
                    echo "Primary key column found: $pkColumn"

                    while true; do
                        read -p "Enter data for $pkColumn ($pkType): " idInput

                        if [ "$pkType" == "int" ] && ! [[ "$idInput" =~ ^[0-9]+$ ]]; then
                            echo "Invalid input. Enter a number for $pkColumn."
                        elif [ "$pkType" == "string" ] && grep -q "^$idInput:" "$filePath"; then
                            echo "Duplicate value. Enter a different $pkColumn."
                        elif [ "$pkType" == "int" ] && grep -q "^$idInput:" "$filePath"; then
                            echo "Duplicate value. Enter a different $pkColumn."
                        elif [ -z "$idInput" ] || [[ "$idInput" =~ ^[[:space:]]+$ ]]; then
                            echo "$pkColumn cannot be empty or contain only spaces. Enter a valid value."
                        else
                            break
                        fi
                    done

                  echo -n "$idInput:" >> "$filePath"

for columnInfo in "${columns[@]}"; do
    IFS=':' read -r columnName dataType <<< "$columnInfo"
    if [ "$columnName" != "$pkColumn" ]; then
        echo "Enter data for $columnName ($dataType):"

        read -r inputData

        while [[ -z "$inputData" || "$inputData" =~ ^[[:space:]]+$ ]]; do
            echo "$columnName cannot be empty or contain only spaces. Enter a valid value:"
            read -r inputData
        done

        if [ "$dataType" == "int" ]; then
            until [[ "$inputData" =~ ^[0-9]+$ ]]; do
                echo "Invalid input. Enter a number for $columnName:"
                read -r inputData
            done
        fi

        echo -n "$inputData:" >> "$filePath"
    fi
done


sed -i 's/:$//' "$filePath"

                   

                    echo "" >> "$filePath"  
                    echo "Data inserted successfully into table '$tableName'."
                    break
                else
                    echo "Error: Primary key column not found in metadata for table '$tableName'."
                    echo "Columns in metadata file: ${columns[@]}"
                fi
            else
                echo "Metadata file not found for table '$tableName'."
            fi
        else
            echo "No file found for table '$tableName'."
            while true; do
                read -p "Do you want to enter another table name? (y/n): " answer

                if [ "$answer" == "y" ]; then
                    break
                elif [ "$answer" == "n" ]; then
                    exit 0
                else
                    echo "Invalid input. Please try again."
                fi
            done
        fi
    done
}
