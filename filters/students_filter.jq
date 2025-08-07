[.[].students.data[] | select(.campus_id | IN($ids[][])) | INDEX(. | .sais_id = (.sais_id | tostring); .sais_id)]
