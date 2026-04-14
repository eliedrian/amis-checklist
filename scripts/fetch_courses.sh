#!/bin/sh

set -e

MAXWAIT=13

while getopts o:n args; do
		case "${args}" in
				o) # -o sets output
						OUTPUT_FILE=${OPTARG}
						;;
				n) # -n turn off wait
						MAXWAIT=0
						;;
				*)
						echo "Wrong arguments"
						exit
						;;
		esac
done


# Base URL of the API (example with ?page=)
#https://api-amis.upcebu.edu.ph/api/courses?page=1&items=5&order_type=ASC&order_field=course_code&with_requisites=true&title_like=&course_code_like=cmsc
BASE_URL="https://api-amis.upcebu.edu.ph/api/admins/courses"
HEADERS_FILE="headers.txt"
PAGE_SIZE=2500
QUERY_PARAMETERS="&items=${PAGE_SIZE}&order_type=ASC&order_field=course_code&with_requisites=true&title_like=&course_code_like=--"

# Start page
PAGE=1
# Flag for stopping condition
HAS_MORE=true

# Empty output file first
> "$OUTPUT_FILE"

while [ "$HAS_MORE" = true ]; do
    echo "Fetching page $PAGE..."
    
    # Fetch data
	RESPONSE=$(curl \
		--compressed \
		-H "Authorization: Bearer ${API_TOKEN}" \
		-H @$HEADERS_FILE \
		${BASE_URL}?page=${PAGE}${QUERY_PARAMETERS})

    # Append response to file
    echo "$RESPONSE" >> "$OUTPUT_FILE"

	TOTAL=$(echo "$RESPONSE" | jq '.[].total')
    TO=$(echo "$RESPONSE" | jq '.[].to')
    if [ "$TO" -eq "$TOTAL" ]; then
        HAS_MORE=false
		break
    else
        PAGE=$((PAGE + 1))
    fi

	if [ "$MAXWAIT" -ne "0" ]; then
			echo "Adding random wait..."
			sleep $(( ( RANDOM % $MAXWAIT )  + 1 ))
	fi
done

echo "All pages fetched into $OUTPUT_FILE"


