#!/bin/bash

SVC_URL="http://articles-publish-cloud-native-starter.openshift-serverless-cl-ecf58268eb10995f067698dffc82d2a7-0000.eu-gb.containers.appdomain.cloud/v2/articles"
AUTHOR="Niklas Heidloff"
TITLE_PRE="Example Article"
BLOG_URL="http://heidloff.net"

function publish_articles {
  for i in {1..100}
  do
    JSON="{\"author\":\"$AUTHOR\",\"url\":\"$BLOG_URL\",\"title\":\"$TITLE_PRE $i\"}"
    echo Publishing $JSON
    curl -X POST \
      $SVC_URL -H "accept: application/json" -H "Content-Type: application/json" \
        -d "$JSON"
      sleep 1
    printf "\n\n"
  done
}

publish_articles
