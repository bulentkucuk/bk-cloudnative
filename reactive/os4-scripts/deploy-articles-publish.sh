#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deploying articles-publish
  
  _out Cleanup
  kn service delete articles-publish
  
  cd ${root_folder}/articles-publish/src/main/resources
  sed -e "s/KAFKA_BOOTSTRAP_SERVERS/my-cluster-kafka-external-bootstrap.kafka:9094/g" \
      -e "s/IN_MEMORY_STORE/false/g" \
      -e "s/POSTGRES_URL/database-articles.postgres-cn-starter:5432/g" \
       application.properties.template > application.properties

  cd ${root_folder}/articles-publish
  oc new-build --name build-articles-publish --binary --dockerfile=Dockerfile.Native
  oc start-build build-articles-publish --from-dir=.
  
  #BK: Serverless run
  kn service create articles-publish \
    --image image-registry.openshift-image-registry.svc:5000/cloud-native-starter/build-articles-publish:latest \
    --env-from cm:articles-config
   
  _out Done deploying articles-publish
}

setup