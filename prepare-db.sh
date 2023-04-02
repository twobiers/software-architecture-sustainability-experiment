#!/usr/bin/env sh

set -eo pipefail

#if [ ! -f "data/openfoodfacts-mongodbdump.tar.gz" ]
#then
#  wget -O data/openfoodfacts-mongodbdump.tar.gz https://static.openfoodfacts.org/data/openfoodfacts-mongodbdump.tar.gz
#fi
#
#if [ ! -d "data/dump" ]
#then
#  tar -xzf data/openfoodfacts-mongodbdump.tar.gz -C data
#fi
#
#docker cp data/dump mongo:/dump
#docker exec mongo sh -c 'exec mongorestore --drop ./dump'

if [ ! -f "data/listingsAndReviews.json" ]
then
  wget -O data/listingsAndReviews.json https://github.com/neelabalan/mongodb-sample-dataset/raw/main/sample_airbnb/listingsAndReviews.json
fi

docker cp data/listingsAndReviews.json mongo:/listingsAndReviews.json
docker exec mongo sh -c 'exec mongoimport --db airbnb --collection listingsAndReviews --file ./listingsAndReviews.json'
