#!/usr/bin/env sh

set -eo pipefail

if [ ! -f "data/listingsAndReviews.json" ]
then
  wget -O data/listingsAndReviews.json https://github.com/neelabalan/mongodb-sample-dataset/raw/main/sample_airbnb/listingsAndReviews.json
fi

docker cp data/listingsAndReviews.json mongo:/listingsAndReviews.json
docker exec mongo sh -c 'exec mongoimport --db airbnb --collection listingsAndReviews --file ./listingsAndReviews.json'
