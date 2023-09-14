#!/bin/sh

# Directory to search in
DIRECTORY="./"

echo "Would you like to update a string or delete a section? (update/delete)"
read action

case $action in
    update)
        # Ask for the old and new strings
        echo "Enter the string you want to update:"
        read old_string

        echo "Enter the new string:"
        read new_string

        # Escape special characters in the input strings
        old_string_escaped=$(echo "$old_string" | sed 's/[&/\]/\\&/g')
        new_string_escaped=$(echo "$new_string" | sed 's/[&/\]/\\&/g')

        # Update the string
        find "$DIRECTORY" -type f -name "*.html" -exec sed -i '' "s/$old_string_escaped/$new_string_escaped/g" {} +

        echo "Update complete."
        ;;

    delete)
        # Ask for the start and end patterns of the section to delete
        echo "Enter the start pattern of the section you want to delete:"
        read start_pattern

        echo "Enter the end pattern of the section:"
        read end_pattern

        # Delete the section
        find "$DIRECTORY" -type f -name "*.html" -exec sed -i '' "/$start_pattern/,/$end_pattern/d" {} +

        echo "Deletion complete."
        ;;

    *)
        echo "Invalid choice. Exiting."
        ;;
esac
