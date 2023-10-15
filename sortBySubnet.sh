#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <ip_list>"
    exit 1
fi

# get arg, make tmp outs
ip_list="$1"
sorted_ips=$(mktemp)
unique_subnets=$(mktemp)

# subnet fn 
get_subnet() {
  echo "$1" | cut -d. -f1-3
}

# sort ips by octet
sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n -u "$ip_list" > "$sorted_ips"

# if we haven't seen it, add it
while read -r ip; do
  subnet=$(get_subnet "$ip")
  if ! grep -q "^$subnet$" "$unique_subnets"; then
    echo "$subnet" >> "$unique_subnets"
    echo "$ip"
  fi
done < "$sorted_ips"

rm "$sorted_ips" "$unique_subnets"

