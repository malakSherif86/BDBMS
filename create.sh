############# Function to create a table ##########
getValidTableName() {
    while true; do
        read -p "Enter the name for the new table: " tableName

        if [ -z "$tableName" ]; then
            echo "Table name cannot be empty. Try again."
            continue
        fi

       
        tableName="${tableName// /_}"

        if [[ ! "$tableName" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            echo "Invalid table name. Try again."
            continue
        fi

        filePath="./${tableName}"
        metadataFile="./.${tableName}"

        if [ -e "$filePath" ] || [ -e "$metadataFile" ]; then
            echo "Table '$tableName' or metadata file already exists. Choose a different name. Try again."
            continue
        fi

        while true; do
            read -p "please note that the PK will be the first column you insert ,Enter the number of columns for the table: " numColumns

            if [ -z "$numColumns" ]; then
                echo "Number of columns cannot be empty. Please enter a positive integer. Try again."
                continue
            elif ! [[ "$numColumns" =~ ^[1-9][0-9]*$ ]]; then
                echo "Invalid number of columns. Please enter a positive integer. Try again."
                continue
            fi
            break
        done

        touch "$metadataFile"

        if [ "$numColumns" -gt 0 ]; then
            touch "$filePath"
            echo "Table '$tableName' created successfully at $filePath"
            break
        else
            echo "Table cannot be created without columns. Please enter a positive number of columns."
        fi
    done

    pkName=""
    for ((i = 1; i <= numColumns; i++)); do
        while true; do
            read -p "Enter the name for column $i: " colName
 colName="${colName// /_}"

            if [ "$colName" == "ID" ]; then
                echo "ID is reserved. Please choose a different column name."
                continue
            elif [ -z "$colName" ]; then
                echo "Column name cannot be empty. Try again."
                continue
            elif ! [[ "$colName" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                echo "Invalid column name. Please enter a valid name."
                continue
            else
                break
            fi
        done

        while true; do
            read -p "Enter the data type for column $colName (int/string): " colType

            if [ "$colType" != "int" ] && [ "$colType" != "string" ]; then
                echo "Invalid data type. Please enter 'int' or 'string'."
                continue
            else
                break
            fi
        done

        if [ -z "$pkName" ]; then
            pkName=$colName
            echo "Primary key is $pkName (default for the first column)"
            echo "$colName:$colType:pk" >> "$metadataFile"
        else
            echo "$colName:$colType" >> "$metadataFile"
        fi
    done

    echo "Table Created!!"
}

