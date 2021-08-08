#!/usr/bin/env bash

CONTAINER_ID=$(docker run --name zap -u zap -d -p 8090:8080 -i owasp/zap2docker-stable zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.disablekey=true -config scanner.attackOnStart=true -config view.mode=attack -config connection.dnsTtlSuccessfulQueries=-1 -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true)

# the target URL for ZAP to scan
TARGET_URL=$1

docker exec $CONTAINER_ID zap-cli -p 8080 status -t 120 && docker exec $CONTAINER_ID zap-cli -p 8080 open-url $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 8080 spider $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 8080 active-scan -r $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 8080 alerts

# docker logs [container ID or name]
divider==================================================================
printf "\n"
printf "$divider"
printf "ZAP-daemon log output follows"
printf "$divider"
printf "\n"

docker logs $CONTAINER_ID

docker stop $CONTAINER_ID
