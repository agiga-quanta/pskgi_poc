#!/bin/bash

cd $1

docker build -t nghiadh/$1:$2 .
docker push nghiadh/$1:$2
docker image prune -f

cd ..
