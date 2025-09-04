#!/bin/sh

# Base URL of the API (example with ?page=)
BASE_URL="https://api-amis.upcebu.edu.ph/api/admins/student-grades"
OUTPUT_FILE="testgrades.json"
HEADERS_FILE="headers.txt"
PAGE_SIZE=2500
QUERY_PARAMETERS="&items=${PAGE_SIZE}&order_type=DESC&order_field=id&access_permission=student_grades_edit&campus_id_like=--&term_like=--&course_code_like=--"

# Start page
PAGE=1
# Flag for stopping condition
HAS_MORE=true

# Empty output file first
> "$OUTPUT_FILE"

while [ "$HAS_MORE" = true ]; do
    echo "Fetching page $PAGE..."
    
    # Fetch data
	RESPONSE=$(curl -v \
		-H "Authorization: Bearer ${API_TOKEN}" \
		-H @$HEADERS_FILE \
		${BASE_URL}?page=${PAGE}${QUERY_PARAMETERS})

    # Append response to file
    echo "$RESPONSE" >> "$OUTPUT_FILE"
	HAS_MORE=false

    # ---- Pagination logic ----
    # Adjust this depending on the API
    # Example 1: If the API returns fewer than 100 items, stop
    #COUNT=$(echo "$RESPONSE" | jq '.data | length')
    #if [ "$COUNT" -lt "$PAGE_SIZE" ]; then
    #    HAS_MORE=false
    #else
    #    PAGE=$((PAGE + 1))
    #fi

    # Example 2: If API explicitly gives "next" link
    NEXT=$(echo "$RESPONSE" | jq -r '.next')
    if [ "$NEXT" = "null" ]; then
        HAS_MORE=false
    else
        BASE_URL="$NEXT"
    fi
done

echo "All pages fetched into $OUTPUT_FILE"
