#!/bin/sh

set -e

WAIT=30

while getopts s:t:o:n args; do
		case "${args}" in
				s) # -s sets prefix student number
						CAMPUS_ID_LIKE=${OPTARG}
						;;
				t) # -t sets term prefix
						TERM_LIKE=${OPTARG}
						;;
				o) # -o sets output
						OUTPUT_FILE=${OPTARG}
						;;
				n) # -n turn off wait
						WAIT=0
						;;
				*)
						echo "Wrong arguments"
						exit
						;;
		esac
done


# Base URL of the API (example with ?page=)
BASE_URL="https://api-amis.upcebu.edu.ph/api/admins/student-grades"
HEADERS_FILE="headers.txt"
PAGE_SIZE=2500
QUERY_PARAMETERS="&items=${PAGE_SIZE}&order_type=DESC&order_field=id&access_permission=student_grades_edit&campus_id_like=${CAMPUS_ID_LIKE}&term_like=${TERM_LIKE}&course_code_like=--"

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

	TOTAL=$(echo "$RESPONSE" | jq '.[].total')
    TO=$(echo "$RESPONSE" | jq '.[].to')
	LAST_PAGE=$(echo "$RESPONSE" | jq '.[].last_page')
	if [ "$LAST_PAGE" -eq "$PAGE" ]; then
		HAS_MORE=false
    else
        PAGE=$((PAGE + 1))
    fi

    # Append response to file
    echo "$RESPONSE" >> "$OUTPUT_FILE"

	if [ "$WAIT" -ne "0" ] && [ $HAS_MORE = true ]; then
			echo "Adding wait..."
			sleep "$WAIT"
	fi
done

echo "All pages fetched into $OUTPUT_FILE"
