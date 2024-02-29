#!/bin/bash



DBMS_DIR="dbms"
# CURRENT_DB=""

# Function to replace spaces with underscores in the database name
input_checker() {
    echo "$1" | tr ' ' '_'
}

# Global variables
tableName=""
filePath=""

# Function to check if a string is a valid database name
is_valid_db_name() {
    db_name=$1
     
     # Check if the input is empty
    if [[ -z "$db_name" ]]; then
        echo "Error: Database name cannot be empty. Please enter a valid name."
        return 1
    fi

    # Check if it's a reserved keyword
    if [[ "$db_name" =~ ^(create|list|drop|connect|from|select|update|delete)$ ]]; then
        echo "Warning: '$db_name' is a reserved keyword. Please choose a different name."
        return 1
    fi

    # Check if it starts with a number
    if [[ "$db_name" =~ ^[0-9] ]]; then
        echo "Warning: Database name cannot start with a number."
        return 1
    fi

    # Check for spaces
    if [[ "$db_name" =~ \  ]]; then
        echo "Warning: Spaces in the database name will be replaced with underscores."
    fi
    

    return 0
}

# Function to create a database
create_database() {
    read -p "Enter the name for the new database: " db_name
    validDB_name=$(input_checker "$db_name")

    if is_valid_db_name "$validDB_name"; then
        if [ -d "$DBMS_DIR/$validDB_name" ]; then
            echo "Warning: Database '$validDB_name' already exists."
        else
            mkdir "$DBMS_DIR/$validDB_name"
            echo "Database '$validDB_name' was created successfully."
        fi
    else
        echo "Warning: Invalid database name. Please try again."
    fi
}

# Function to list only database directories
list_databases() {
    local dbms_dir="dbms"
    echo "List of databases:"
    for dir in "$dbms_dir"/*/; do
        if [ -d "$dir" ]; then
            echo "${dir#$dbms_dir}"
        fi
    done
    
}

# Function to drop a database
drop_database() {
    while true; do
        
        read -p "Enter the name of the database you want to remove: " db_name

        
        if [[ -z "$db_name" || ! "$db_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
            echo "Invalid database name. Please enter a valid name without spaces or special characters."

            
            read -p "press any button to try agian and 'n' to go back to main menu: " try_again
            if [ "$try_again" == "n" ]; then
                break
            else
                continue
            fi
        fi

        
        validDB_name=$(input_checker "$db_name")

        
        if [ -d "$DBMS_DIR/$validDB_name" ]; then
            
            read -p "Are you sure you want to remove database '$validDB_name'? (y/n): " confirm
            if [ "$confirm" == "y" ]; then
                
                rm -r "$DBMS_DIR/$validDB_name"
                echo "Database '$validDB_name' removed successfully."
                break
            else
                echo "Removal canceled. Database '$validDB_name' not removed."
                break
            fi
        else
            
            echo "Warning: Database '$db_name' not found. Please try again."
        fi
    done
}
# Function to Disconnecting
disconnecting() {
    echo "Disconnecting from $validDB_name, Goodbye"
    cd ../..
    break
}

# Function to connect to a database and contain all the db features 
connect_to_database() {
    read -p "Enter the name of the database you want to connect to: " db_name
    validDB_name=$(input_checker "$db_name")

    if [ -d "$DBMS_DIR/$validDB_name" ]; then
        cd "$DBMS_DIR/$validDB_name"
        echo "Connected to database '$validDB_name'."
        # here is the start of our dbms mean function as we are actually inside the database directory

        # dbms mean menu
        while true; do
            echo -e "you are now inside $validDB_name database please select any number from 1 to 7 "
            echo "1. Create Table"
            echo "2. List All Tables"
            echo "3. Drop Table"
            echo "4. SELECT"
            echo "5. INSERT"
            echo "6. UPDATE"  
            echo "7. delete from table"
            echo "8. Disconnect from database"

            read -p "Enter your choice 1-7: " dbms_mean_menu_choice
            
            case $dbms_mean_menu_choice in
                1) getValidTableName ;;
                 2)  viewAllTables;;
                  3) dropTable  ;;
                 4) big_select ;;
                  5) insert_data ;;
                6) big_update ;;
                7) big_delete ;;
               8) disconnecting ;;
                *) echo "Invalid choice, Please enter a number between 1 and 7." ;;
            esac
        done

        # end of our dbms function as we will disconnect from the database
    else
        echo "Warning: Database '$validDB_name' not found."
    fi
}
#########################################################



# Check if DBMS directory exists, create it if not
if [ ! -d "$DBMS_DIR" ]; then
    mkdir "$DBMS_DIR"
fi

# Main menu
while true; do
    echo -e "\nDBMS Menu:"
    echo "1. Create Database"
    echo "2. List All Databases"
    echo "3. Drop Database"
    echo "4. Connect to Database"
    echo "5. Exit"

    read -p "Enter your choice 1-5: " choice

    case $choice in
        1) create_database ;;
        2) list_databases ;;
        3) drop_database ;;
        4) connect_to_database ;;
        5) echo "Exiting DBMS. Goodbye"; exit ;;
        *) echo "Invalid choice, Please enter a number between 1 and 5." ;;
    esac
done

