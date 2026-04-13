[$students[][] as $s | ($s | map({key: .user_id, value: .}) | from_entries) as $index | $users[] | select($index[.id]) | . + $index[.id]]
