curl -w '\n' -X POST %1 -H "Content-Type: application/json" -H "Accept: application/json" -d @%2 | python -m json.tool
