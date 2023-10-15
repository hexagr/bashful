#!/bin/bash

# hit crt.sh api and web interface. -r flag to clean any
# urls with wildcards while preserving said urls,
# to pass data to other tooling etc.

# initialize wildcard removal flag to false
remove_wildcards=false

# parse options
while getopts "r" opt; do
    case $opt in
        r)
            remove_wildcards=true
            ;;
        \?)
            echo "Usage: $0 [-r] <domain>"
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

# check if a domain argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [-r (remove asterisks)] <domain>"
    exit 1
fi

# get domain name
target_domain="$1"

# fetch crt.sh output using api
crtsh_output_api=$(curl -s "https://crt.sh/?q=%25.${target_domain}&output=json")

# extract subdomains from json
extracted_domains_api=$(echo "$crtsh_output_api" | jq -r '.[].name_value' | sort -u)

# fetch crt.sh output as html
crtsh_output_html="crtsh_output.html"
curl -s "https://crt.sh/?q=%25.${target_domain}" > "$crtsh_output_html"

# extract subdomains from html
extracted_domains_html=$(grep -ioE "([*]?[a-zA-Z0-9-]+\.$target_domain)" "$crtsh_output_html" | sort -u)

# combine, save only unique entries
combined_domains=$(echo -e "$extracted_domains_api\n$extracted_domains_html" | sort -u)

# define output file for combined extraction
output_file_combined="$1"

# fn to remove wildcards from subdomains
remove_wildcards() {
    sed 's/^\*\.//'
}

# save combined subdomains with or without wildcard asterisks
# to pass output to other tools, hassle free 
if $remove_wildcards; then
    echo "$combined_domains" | remove_wildcards > "$output_file_combined"
    echo "Combined unique subdomains (asterisks removed) saved to: $output_file_combined"
else
    echo "$combined_domains" > "$output_file_combined"
    echo "Combined unique subdomains saved to: $output_file_combined"
fi

# compare counts
echo "Subdomains extracted from API: $(echo "$extracted_domains_api" | wc -l)"
echo "Subdomains extracted from web: $(echo "$extracted_domains_html" | wc -l)"
echo "Total unique subdomains found: $(echo "$combined_domains" | wc -l)"

rm $crtsh_output_html
