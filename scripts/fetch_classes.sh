#!/bin/sh

set -e

MAXWAIT=13

while getopts t:o:n args; do
		case "${args}" in
				t) # -t sets term prefix
						TERM_LIKE=${OPTARG}
						;;
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
# https://api-amis.upcebu.edu.ph/api/admins/classes?page=1&items=5&with_classes=true&with_schedule=true&with_other_fics=true&with_faculty_assigned=true&access_permission=can+update+classes&access_type=admins&course_code_like=cmsc&section_like=--&consent=--&term_name=--
BASE_URL="https://api-amis.upcebu.edu.ph/api/admins/classes"
HEADERS_FILE="headers.txt"
PAGE_SIZE=1000
QUERY_PARAMETERS="&items=${PAGE_SIZE}&with_classes=true&with_schedule=true&with_other_fics=true&with_faculty_assigned=true&access_permission=can+update+classes&access_type=admins&course_code_like=--&section_like=--&consent=--&term_name_like=${TERM_LIKE}"

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

