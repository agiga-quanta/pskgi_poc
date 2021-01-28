#!/bin/bash

./gather_neo4j_plugins.sh
docker-compose pull
docker-compose up --no-build
docker-compose down
