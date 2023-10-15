#!/bin/bash

# sort a list of domains by subnet uniqueness

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <domain_file>"
    exit 1
fi

domain_file="$1"
output_file=$(mktemp)
unique_ips=$(mktemp)

get_subnet() {
  echo "$1" | cut -d. -f1-3
}

cat "$domain_file" | \
httpx -H "User-Agent: Mozilla 5.0" -threads 100 -timeout 1 -ip -j 2>/dev/null | \
jq -r '.host' | while read -r ip; do
  subnet=$(get_subnet "$ip")
  if ! grep -q "^$subnet$" "$unique_ips"; then
    echo "$subnet" >> "$unique_ips"
    echo "$ip"
  fi
done > "$output_file"

sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n -u "$output_file"

rm "$output_file" "$unique_ips"

