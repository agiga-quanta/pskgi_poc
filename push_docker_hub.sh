#!/bin/bash

cd nlp

docker build -t nghiadh/nlp:0.1.0 .
docker push nghiadh/nlp:0.1.0
docker image prune -f

cd ..
