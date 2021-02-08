#!/bin/sh

echo 'Example: ./test_tika.sh http://localhost:9998/tika ../import/salmon_anatomy_vocabulary_list.pdf'

curl -X PUT --data-binary @$2 -H "Content-Type: application/pdf" $1
