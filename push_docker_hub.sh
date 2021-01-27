#!/bin/bash

cd nlp

docker build -t nghiadh/nlp:$1 .
docker push nghiadh/nlp:$1
docker image prune -f

cd ..
