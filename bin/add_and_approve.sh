#!/bin/bash


## expect $ZOOMAT env varilabe presents for access token
export MEETINGID=$1
export INPUT_DIR=$2
export LANGUAGE=$3
export dryrun="false"

if [ $dryrun != "true" ]
then
    ## set the language
    curl -X PATCH  \
    --header "Authorization: Bearer $ZOOMAT"  \
    --header 'content-type: application/json' \
    "https://api.zoom.us/v2/users/me" -d "{\"language\": \"$LANGUAGE\"}"
fi

file="$INPUT_DIR/${LANGUAGE}.json"
for file in $INPUT_DIR/${LANGUAGE}*.json.split*; do
    while read -r line; do
        echo "input: $line"

        ## add registrant, in pending state
        if [ $dryrun != "true" ]
        then
            curl -X POST --header "Authorization: Bearer $ZOOMAT" \
            --header 'content-type: application/json' \
            "https://api.zoom.us/v2/meetings/${MEETINGID}/registrants" -d "$line"
        fi

        echo " "

        ## sleep to avoid hitting rate limit
        sleep 0.3
    done < "$file"
    echo "done $file"
    echo ""

    sleep 0.5

    export toApprove=$(cat $file | jq -s '[.[] | {email}]')
    echo "Will approve $toApprove\n"

    if [ $dryrun != "true" ]
    then
        curl -X PUT \
         --header "Authorization: Bearer $ZOOMAT"  \
         --header 'content-type: application/json' \
         "https://api.zoom.us/v2/meetings/${MEETINGID}/registrants/status" \
        -d " {
          \"action\": \"approve\",
          \"registrants\": $toApprove
        }"
    fi

    echo ""

done



