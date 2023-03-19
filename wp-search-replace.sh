#!/bin/bash

while true; do
    echo "Enter the search term:"
    read search_term

    echo "Enter the replacement term:"
    read replace_term

    echo "You entered the following values:"
    echo "Search term: $search_term"
    echo "Replace term: $replace_term"

    read -p "Are these values okay? (y/n) " confirm
    case $confirm in
        [Yy]* ) break;;
        [Nn]* ) unset search_term replace_term; continue;;
        * ) echo "Please answer y or n.";;
    esac
done

echo "Executing the following command: wp search-replace \"$search_term\" \"$replace_term\""
read -n 1 -p "Press enter to execute the command, or 'n' to restart: " execute
echo ""

if [ "$execute" == "n" ]; then
    echo "Restarting script..."
    unset search_term replace_term
    exec $0
else
    wp search-replace "$search_term" "$replace_term"
    unset search_term replace_term
fi
