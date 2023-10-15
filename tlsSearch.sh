#!/bin/bash

# case-insensitive search of tls certs by cidr block 

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <cidr> <search_key>"
    exit 1
fi

cidr="$1"
search_key="$2"

declare -a unique_ips

mapcidr -cl "$cidr" 2>/dev/null | \
tlsx -ex -ss -mm -re -un -timeout 1 -json 2>/dev/null | \
jq -r "select(recurse | strings | test(\"$search_key\"; \"i\")).ip" | \
while read -r ip; do
    if [[ ! " ${unique_ips[@]} " =~ " $ip " ]]; then
        unique_ips+=("$ip")
        echo "$ip"
    fi
done
