#!/usr/bin/env bash

set -eo pipefail

if [ ! -f "data/openfoodfacts-mongodbdump.tar.gz" ]; then
  wget -O data/openfoodfacts-mongodbdump.tar.gz https://static.openfoodfacts.org/data/openfoodfacts-mongodbdump.tar.gz
fi

if [ ! -d "data/dump" ]; then
  tar -xzf data/openfoodfacts-mongodbdump.tar.gz -C data
fi

docker cp data/dump mongo:/dump
docker exec mongo sh -c 'exec mongorestore --drop ./dump'
