
############# Function to list table ##########
function viewAllTables {
    echo "Tables in '$validDB_name':"

    ls -1
}
#########################################################
############# Function to drop table ##########

function validateTableName {
    local tableName="$1"

    if [ -z "$tableName" ] || [[ ! "$tableName" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Invalid table name. Please Try Again."
        return 1
    fi

    return 0
}

function dropTable {
    while true; do
        read -p "Enter the name of the table you want to drop: " dropTableName

        if ! validateTableName "$dropTableName"; then
            continue
        fi

        dropFilePath="./${dropTableName}"
        metadataFilePath="./.${dropTableName}"

        if [ -e "$dropFilePath" ]; then
            while true; do
                read -p "Are you sure you want to drop table '$dropTableName'? (y/n): " dropConfirmation

                case $dropConfirmation in
                    [Yy]*)
                        rm "$dropFilePath"
                        echo "Table '$dropTableName' dropped successfully."

                        if [ -e "$metadataFilePath" ]; then
                            rm "$metadataFilePath"
                            echo "Metadata file for '$dropTableName' dropped as well."
                        else
                            echo "Metadata file for '$dropTableName' not found."
                        fi

                        return
                        ;;
                    [Nn]*)
                        echo "Table '$dropTableName' not dropped."
                        return
                        ;;
                    *)
                        echo "Invalid input. Please enter 'y' or 'n'."
                        ;;
                esac
            done
        else
            echo "Table '$dropTableName' not found."
        fi
    done
}

