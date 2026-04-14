#!/bin/sh

MAXWAIT=13

while getopts s:t:o:n args; do
		case "${args}" in
				s)
						CAMPUS_ID_LIKE=${OPTARG}
						;;
				o)
						OUTPUT_FILE=${OPTARG}
						;;
				n)
						MAXWAIT=0
						;;
				*)
						echo "Wrong arguments"
						exit
						;;
		esac
done


# Base URL of the API (example with ?page=)
# https://api-amis.upcebu.edu.ph/api/admins/students?access_permission=enlistment_manage&items=2500
BASE_URL="https://api-amis.upcebu.edu.ph/api/admins/students"
HEADERS_FILE="headers.txt"
PAGE_SIZE=2500
QUERY_PARAMETERS="&items=${PAGE_SIZE}&student_number_like=${CAMPUS_ID_LIKE}&access_permission=enlistment_manage&order_field=id"

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

    # ---- Pagination logic ----
    # Adjust this depending on the API
    # Example 1: If the API returns fewer than 100 items, stop
	TOTAL=$(echo "$RESPONSE" | jq '.[].total')
    TO=$(echo "$RESPONSE" | jq '.[].to')
    if [ "$TO" -eq "$TOTAL" ]; then
        HAS_MORE=false
		break
    else
        PAGE=$((PAGE + 1))
    fi

    # Example 2: If API explicitly gives "next" link
    #NEXT=$(echo "$RESPONSE" | jq -r '.[].next_page_url')
    #if [ "$NEXT" = "null" ]; then
    #    HAS_MORE=false
    #else
    #    BASE_URL="$NEXT"
    #fi
	if [ "$MAXWAIT" -ne "0" ]; then
			echo "Adding random wait..."
			sleep $(( ( RANDOM % $MAXWAIT )  + 1 ))
	fi
done

echo "All pages fetched into $OUTPUT_FILE"
