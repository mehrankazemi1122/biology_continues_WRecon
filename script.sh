#!/bin/bash

# Check if arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <wordlist_file> <website_address>"
    exit 1
fi

# Assign arguments to variables
wordlist_file="$1"
website_address="$2"

# Step 1: Run shuffledns command
shuffledns -w "$wordlist_file" -d "$website_address" -r resolvers.txt -m massdns/bin/massdns -o "output.${website_address}.txt" -mode bruteforce

# Step 2: Remove duplicates from output file
cat "output.${website_address}.txt" | sort -u | sponge "output.${website_address}.txt"
cat "prev_output.${website_address}.txt" | sort -u | sponge "prev_output.${website_address}.txt"

# Step 3: Compare with previous output and send additions to Discord
added_subdomains=$(comm -23 "output.${website_address}.txt" "prev_output.${website_address}.txt")
if [ -n "$added_subdomains" ]; then
    echo "subdomains Added:"
    echo "$added_subdomains" | while IFS= read -r line; do
        curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"subdomains Added: $line\"}" https://discord.com/api/webhooks/1257309085351542786/ijyiMHCcmhafcTqgumjZkLFLJAOuPvvgTqNdas3Rg3v1uHr8Qf07TNLq_Oo1JYajBlM8
    done
fi

# Step 4: Compare with previous output and send deletions to Discord
deleted_subdomains=$(comm -23 "prev_output.${website_address}.txt" "output.${website_address}.txt")
if [ -n "$deleted_subdomains" ]; then
    echo "subdomains Deleted:"
    echo "$deleted_subdomains" | while IFS= read -r line; do
        curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"subdomains Deleted: $line\"}" https://discord.com/api/webhooks/1257309085351542786/ijyiMHCcmhafcTqgumjZkLFLJAOuPvvgTqNdas3Rg3v1uHr8Qf07TNLq_Oo1JYajBlM8
    done
fi

# Step 5: Replace previous output file with current output file
rm -f "prev_output.${website_address}.txt"
mv "output.${website_address}.txt" "prev_output.${website_address}.txt"
