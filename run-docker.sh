#!/usr/bin/env bash

Help()
{
   # Display Help
   echo "Tool to run ZAP container."
   echo
   echo "Syntax: scriptTemplate [-t|r|n|a]"
   echo "options:"
   echo "t     Target URL."
   echo "r     (opt) Output report name (found in pwd/report/). Default report.html"
   echo "n     (opt) Number of alerts to cause failure. Default 0"
   echo "a     (opt) Alert level (High|Medium|Low). Default Medium"
   echo "h     (opt) Show this help"
   echo
}

TARGET_URL=none
REPORT_OUT=report.html
MAX_ALERTS=0
ALERT_LEVEL=Medium

while getopts t:r:n:a:h flag
do
    case "${flag}" in
        t) TARGET_URL=${OPTARG};;
        r) REPORT_OUT=${OPTARG};;
        n) MAX_ALERTS=${OPTARG};;
        a) ALERT_LEVEL=${OPTARG};;
		h) 	Help 
			exit 0;;
    esac
done

if [[ $* != *-t* ]]; then
	echo "Requires target"
	exit 1
fi

mkdir reports
chmod 777 reports

CONTAINER_ID=$(docker run --name zap -u zap -d -p 8090:8080 -i            \
	-v "$(pwd)/reports":/zap/reports/:rw \
	owasp/zap2docker-stable zap.sh -daemon -host 0.0.0.0 -port 8080   \
	-config api.disablekey=true \
	-config scanner.attackOnStart=true \
	-config view.mode=attack \
	-config connection.dnsTtlSuccessfulQueries=-1 \
	-config api.addrs.addr.name=.* \
	-config api.addrs.addr.regex=true)

docker exec $CONTAINER_ID zap-cli -p 8080 status -t 120 && docker exec $CONTAINER_ID zap-cli -p 8080 open-url $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 8080 spider $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 8080 active-scan -r $TARGET_URL
docker exec $CONTAINER_ID zap-cli -p 8080 report -o reports/$REPORT_OUT -f html

ALERT_NUM=$(docker exec $CONTAINER_ID zap-cli -p 8080 --verbose alerts --alert-level $ALERT_LEVEL -f json | jq length)

divider==================================================================
printf "\n"
printf "$divider"
printf "ZAP-daemon log output follows"
printf "$divider"
printf "\n"

docker logs $CONTAINER_ID

docker stop $CONTAINER_ID
docker rm $CONTAINER_ID

if [[ "${ALERT_NUM}" -gt $MAX_ALERTS ]]; then
  echo "${ALERT_NUM} Alerts found! Please check the Zap Scanning Report"
  exit 1
else
  echo "Less than max alerts observed"
  exit 0
fi

