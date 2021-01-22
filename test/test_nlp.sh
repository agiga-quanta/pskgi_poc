#!/bin/sh

curl -w '\n' -X POST $1 -H "Content-Type: application/json" -H "Accept: application/json" -d @$2 | json_pp
