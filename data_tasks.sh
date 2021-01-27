#!/bin/bash

if [ $# -lt 5 ]; then
  echo "Usage: ./data_tasks.sh <COMMANDS> <NEO4J_CONTAINER> <USER_NAME> <PASSWORD> <BOLT_URL> "
  echo "  COMMAND: "
  echo "      a: add new schema (unique constraints & indexes)"
  echo "      j: nlp and import json file (inside import/ directory)"
  echo "      x: nlp and import data xls(x) file (inside import/ directory)"
  echo "      c: clean up by remove all nodes and relationships"
  echo "      r: remove schema"
  echo "      s: print database statistics"
  echo "      t: test if database ready"
  echo "  EXAMPLES:"
  echo "      ./data_tasks.sh t: test if database ready"
  echo "      ./data_tasks.sh a: add new schema"
  echo "      ./data_tasks.sh j: nlp and import json file"
  echo "      ./data_tasks.sh x: nlp and import data xls(x) file"
  echo "      ./data_tasks.sh c: clear database"
  echo "      ./data_tasks.sh r: remove schema"
  echo "      ./data_tasks.sh cr: run an c -> r pipeline"
  echo "      ./data_tasks.sh s: print database statistics"
  echo "  NEO4J_CONTAINER: the name of the running container, e.g. neo4j"
  echo "  USER_NAME: username to access neo4j database, e.g neo4j"
  echo "  PASSWORD: password to access neo4j database, e.g pskgi"
  echo "  BOLT_URL: Bolt-based URL to access neo4j database, e.g bolt://localhost:7687"
  echo "  EXAMPLES:"
  echo "      ./data_tasks.sh t neo4j neo4j pskgi bolt://localhost:7687"
  exit
fi

res1=$(date +%s)

commands=$1

if [[ $commands == *"a"* ]]; then
  if [ $# -lt 6 ]; then
    echo "Usage: ./data_tasks.sh n <NEO4J_CONTAINER> <USER_NAME> <PASSWORD> <BOLT_URL> <SCHEMA_FILE>"
    echo "  SCHEMA_FILE: the full name of the schema file written in Cypher, e.g. cql/nlp_schema.cql"
  else
    printf "Add new schema ...\n"
    (docker exec -i $2 /var/lib/neo4j/bin/cypher-shell -u $3 -p $4 -a $5) < $6
    printf "Done.\n"
  fi
fi

if [[ $commands == *"j"* ]]; then
  if [ $# -lt 7 ]; then
    echo "Usage: ./data_tasks.sh n <NEO4J_CONTAINER> <USER_NAME> <PASSWORD> <BOLT_URL> <JSON_FILE> <NLP_SERVICE>"
    echo "  JSON_FILE: the full name of the json file (inside import/ directory)"
    echo "  NLP_SERVICE: the URL of the NLP micro service, e.g. http://localhost:8000/process/"
  else
    printf "Import from json file ...\n"
    (docker exec -i $2 /var/lib/neo4j/bin/cypher-shell -u $3 -p $4 -a $5 -P "json_file => \"$6\"" -P "nlp_service => \"$7\"") < cql/import_json.cql
    printf "Done.\n"
  fi
fi

if [[ $commands == *"x"* ]]; then
  if [ $# -lt 6 ]; then
    echo "Usage: ./data_tasks.sh n <NEO4J_CONTAINER> <USER_NAME> <PASSWORD> <BOLT_URL> <XLS_FILE> <NLP_SERVICE>"
    echo "  XLS_FILE: the full name of the xls(x) file (inside import/ directory)"
    echo "  NLP_SERVICE: the URL of the NLP micro service, e.g. http://localhost:8000/process/"
  else
    printf "Import from xls(x) file ...\n"
    (docker exec -i $2 /var/lib/neo4j/bin/cypher-shell -u $3 -p $4 -a $5 -P "xls_file => \"$6\"" -P "nlp_service => \"$7\"") < cql/import_xls.cql
    printf "Done.\n"
  fi
fi

if [[ $commands == *"c"* ]]; then
  printf "Clear database ...\n"
  (docker exec -i $2 /var/lib/neo4j/bin/cypher-shell -u $3 -p $4 -a $5) < cql/clear_db.cql
  printf "Done.\n"
fi

if [[ $commands == *"r"* ]]; then
  printf "Remove schema ...\n"
  (docker exec -i $2 /var/lib/neo4j/bin/cypher-shell -u $3 -p $4 -a $5) < cql/remove_schema.cql
  printf "Done.\n"
fi

if [[ $commands == *"t"* ]]; then
  printf "Test if neo4j database is ready ...\n"
  (docker exec -i $2 /var/lib/neo4j/bin/cypher-shell -u $3 -p $4 -a $5) < cql/test_db.cql
  printf "Done.\n"
fi

if [[ $commands == *"s"* ]]; then
  printf "Snapshot report ...\n"
  (docker exec -i $2 /var/lib/neo4j/bin/cypher-shell -u $3 -p $4 -a $5) < cql/db_report.cql
  printf "Done.\n"
fi

res2=$(date +%s)
diff=`echo $((res2-res1)) | awk '{printf "%02dh:%02dm:%02ds\n",int($1/3600),int($1%3600/60),int($1%60)}'`
printf "\nDONE. Total processing time: %s.\n" $diff
