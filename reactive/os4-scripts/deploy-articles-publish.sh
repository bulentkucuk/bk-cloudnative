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
  oc new-build --name build-articles-publish --binary --strategy docker
  oc start-build build-articles-publish --from-dir=.
  
  #BK: Serverless run
  oc apply -f deployment/configmap.yaml
  kn service create articles-publish \
    --image image-registry.openshift-image-registry.svc:5000/cloud-native-starter/build-articles-publish:latest \
    --env-from cm:articles-config
   
  _out Done deploying articles-publish
  # ROUTE=$(oc get route articles-publish --template='{{ .spec.host }}')
  # _out Wait until the pod has been started: \"kubectl get pod --watch | grep articles-publish\"
  # _out Wait a minute more then test:
  # _out API Explorer: http://$ROUTE/explorer
  # _out Sample API - Read articles: curl -X GET \"http://$ROUTE/v2/articles?amount=10\" -H \"accept: application/json\"
}

setup