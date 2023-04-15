#!/usr/bin/env sh

set -eo pipefail

if [ ! -f "data/demo-big-en.zip" ]
then
  wget -O data/demo-big-en.zip https://edu.postgrespro.com/demo-big-en.zip
fi

if [ ! -f "data/demo-big-en-20170815.sql" ]
then
  unzip -o data/demo-big-en.zip -d data
fi

docker cp data/demo-big-en-20170815.sql postgres-db:/tmp/demo-big-en-20170815.sql
docker exec postgres-db sh -c 'exec psql -U postgres -f /tmp/demo-big-en-20170815.sql'
