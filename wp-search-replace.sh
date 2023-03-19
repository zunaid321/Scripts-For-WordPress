#!/bin/bash

# Change directory to public_html
cd /path/to/public_html || exit

# Ask for search and replace terms
read -p "What should be searched for? " search_term
read -p "What should it be replaced with? " replace_term

# Show the command with dry-run option
echo "The command with dry-run option:"
echo "wp search-replace \"$search_term\" \"$replace_term\" --all-tables --dry-run"

# Confirm before executing the command
read -p "Do you want to run this command? (y/n) " confirm
if [[ "$confirm" == [yY] ]]; then
  # Execute the command without dry-run
  wp search-replace "$search_term" "$replace_term" --all-tables
  # Clear the cache
  rm -rf wp-content/cache
  rm -rf wp-content/et-cache
  wp cache purge
  wp cdn purge
  redis-cli -s ~/redis/redis.sock flushall
  # Go back to the original directory
  cd - || exit
  # Delete the script
  rm "$0"
else
  # Go back to the original directory
  cd - || exit
  # Exit without running the command
  exit 1
fi

exit 0
