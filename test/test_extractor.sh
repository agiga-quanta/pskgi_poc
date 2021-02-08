#!/bin/sh

echo 'Example: ./test_extractor.sh http://localhost:8002/process/ tika_input.json'

curl -w '\n' -X POST $1 -H "Content-Type: application/json" -H "Accept: application/json" -d @$2 | python -m json.tool
