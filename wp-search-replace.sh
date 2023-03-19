#!/usr/bin/env bash

usertestsecurity=$(whoami)
if [[ "$usertestsecurity" == "rocketstaff" ]]  || [[ "$usertestsecurity" == "root" ]]; then
echo "Are you crazy?! Don't run it on rocketstaff or root. Lol, relax, I already did it, so that is why now we have this security check. Exiting."
rm -rf wp-search-replace.sh
exit
fi

# Define functions for repeated tasks
function prompt_for_value {
    local var_name="$1"
    local prompt="$2"
    read -p "$prompt: " "$var_name"
}

function confirm_values {
    local search_term="$1"
    local replace_term="$2"
    echo "You entered the following values:"
    echo "Search term: $search_term"
    echo "Replace term: $replace_term"
    read -rp "Are these values okay? (y/n) " confirm
    [[ "$confirm" =~ ^[Yy]$ ]]
}

# Prompt for search and replace terms
while true; do
    prompt_for_value "search_term" "Enter the search term"
    prompt_for_value "replace_term" "Enter the replacement term"
    if confirm_values "$search_term" "$replace_term"; then
        break
    fi
done

# Save the current working directory and change to public_html directory
current_dir=$(pwd)
cd public_html || { echo "Error: public_html directory not found"; exit 1; }

# Build the command to run
command="wp search-replace \"$search_term\" \"$replace_term\" --precise --all-tables --dry-run"

# Prompt to confirm before executing the command
echo "Dry run of the following command: $command"
read -n 1 -rp "Press enter to continue, or 'n' to restart: " execute
echo ""
if [[ "$execute" =~ ^[Nn]$ ]]; then
    echo "Restarting script..."
    unset search_term replace_term
    cd "$current_dir"
    exec "$0"
else
    # Remove --dry-run from the command
    command="${command/--dry-run/}"
    # Execute the command
    eval "$command"
    rm -rf wp-content/cache
    rm -rf wp-content/et-cache
    wp cache purge
    wp cdn purge
    redis-cli -s ~/redis/redis.sock flushall
    unset search_term replace_term
    cd "$current_dir"
    rm -rf wp-search-replace.sh
exit
fi
