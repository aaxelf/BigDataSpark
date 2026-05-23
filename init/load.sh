#!/usr/bin/env bash
set -e

for i in 0 1 2 3 4 5 6 7 8 9; do
  FILE="/data/MOCK_DATA_($i).csv"
  if [ -f "$FILE" ]; then
    echo "Loading $FILE"
    psql -U postgres -d bigdata_lab <<SQL
\copy staging.mock_data FROM '$FILE' DELIMITER ',' CSV HEADER;
SQL
  else
    echo "File not found: $FILE"
  fi
done