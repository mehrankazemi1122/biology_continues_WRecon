#!/bin/bash

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <website_address>"
    exit 1
fi
 echo "file executed !" 
# Assign argument to variable
website_address="$1"

# Function to send notification to Discord with a delay
send_discord_notification() {
    echo "sending function start !"
    local content="$1"
    local webhook_url="https://discord.com/api/webhooks/1257309085351542786/ijyiMHCcmhafcTqgumjZkLFLJAOuPvvgTqNdas3Rg3v1uHr8Qf07TNLq_Oo1JYajBlM8"

    # Add a delay of 1 second before sending each notification
    sleep 1

    # Escape special characters and format the JSON payload
    local json_payload=$(jq -n --arg content "$content" '{"content":$content}')

    # Send the notification
    curl -H "Content-Type: application/json" -X POST -d "$json_payload" "$webhook_url"
    echo "sending function ends"
}


# Step 1: Run httpx command and save results
echo "main command is executing"
cat "prev_output.${website_address}.txt" | dnsx -silent | httpx -silent -follow-host-redirects -nc -title -status-code -cdn -tech-detect \
        -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:108.0) Gecko/20100101 Firefox/108.0" \
        -H "Referer: $line" | sort -u > httpx_res.txt

# Step 2: Compare with previous httpx results and send changes to Discord
if [ -f "prev_httpx_res.txt" ]; then
    echo "first if approved !"
    changes=$(comm -23 httpx_res.txt prev_httpx_res.txt)
    if [ -n "$changes" ]; then
        echo "second if approved !"
        echo "services changes:"
        while IFS= read -r line; do
            echo "first while approved !"
            prev_line=$(grep -F "$(echo "$line" | awk -F'[[]' '{print $1}')" prev_httpx_res.txt)
            echo "meghdar parameter prev_line : $prev_line"
            echo "previous : $prev_line"
            echo "updated : $line"
            send_discord_notification "services changes: **** previous **** : $prev_line \n**** updated **** : $line\n"
        done <<< "$changes"
    fi
fi

# Step 3: Replace previous httpx results with current results
rm -f "prev_httpx_res.txt"
mv "httpx_res.txt" "prev_httpx_res.txt"
echo "script ends successfully"
