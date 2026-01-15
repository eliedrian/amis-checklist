#!/bin/sh

set -e

MAXWAIT=13

CAMPUS_ID_LIKE=--

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
						MAXWAIT=0
						;;
				*)
						echo "Wrong arguments"
						exit
						;;
		esac
done


# Base URL of the API (example with ?page=)
# https://api-amis.upcebu.edu.ph/api/admins/student-enlistments?page=1&items=5&with_students=true&access_permission=enlistment_manage&status%5B%5D=Enlisted&status%5B%5D=Enrolled&status%5B%5D=Finalized&status%5B%5D=Sent+to+SAIS&term_id=1241&course_code_like=--&student_number=--&name_like=--&program_like=bscs
BASE_URL="https://api-amis.upcebu.edu.ph/api/admins/student-enlistments"
HEADERS_FILE="headers.txt"
PAGE_SIZE=1500
QUERY_PARAMETERS="&items=${PAGE_SIZE}&with_students=true&access_permission=enlistment_manage&status%5B%5D=Enlisted&status%5B%5D=Enrolled&status%5B%5D=Finalized&status%5B%5D=Sent+to+SAIS&term_id=${TERM_LIKE}&course_code_like=--&student_number=${CAMPUS_ID_LIKE}&name_like=--&program_like=bscs"

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
	if [ "$TO" = "null" ] || [ "$TOTAL" = "null" ]; then
			break
	fi
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

