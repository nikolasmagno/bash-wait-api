#!/bin/sh
URL=$1
STATUS_CODE=$2

: ${SLEEP_LENGTH:=2}
: ${TIMEOUT_LENGTH:=300}

wait_for() {
        START=$(date +%s)
        echo "Waiting for $URL return status $STATUS_CODE"
        AGUARDAR= true;

        while $AGUARDAR;
        do
                HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST $URL)

                # extract the body
                HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

                # extract the status
                HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

                # print the body
                #echo "$HTTP_BODY"

                # example using the status
                if [ $HTTP_STATUS -eq $STATUS_CODE ]; then
                        echo "[HTTP status: $HTTP_STATUS] - URL [$URL]"
                        echo "STATUS OK"
                        exit 0
                else
                        echo "[HTTP status: $HTTP_STATUS] - URL [$URL]"
                        echo "STATUS FAIL"
                fi
                echo "Aguardando..."
                sleep $SLEEP_LENGTH
        done
}

for var in "$@"
do
        host=${var%:*}
        port=${var#*:}
        wait_for $host $port
done
