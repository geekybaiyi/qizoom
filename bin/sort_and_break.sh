#!/bin/bash

##input csv file is expected in the following format:
##
## email,first_name,last_name,role,language
## cabaiyin01@foo.com,CA,王大明,CA,zh_TW
## student02@foo.com,TW01,林小明,Student,zh_TW
## student02@foo.com,SG01,李小明,Student,en_US
export INPUT_FILE=$1
export OUTPUT_DIR=$2
export PARTITION_LINECOUNT=30

mkdir -p $OUTPUT_DIR

## group by language
## and output to files 
gawk -v OUTDIR=$OUTPUT_DIR -F "," 'NR==1{ h=$0 }NR>1{ print (!a[$5]++? h ORS $0 : $0) > OUTDIR"/"$5".csv" }' $INPUT_FILE

## partition by line count, because zoom API can only approve 30 registratns at once at most
for file in $OUTPUT_DIR/*.csv; do
    filename=$(basename -- "$file")
    filename="${filename%.*}"
    jq -R -s -f csv2json.jq $file | jq -c .[] > "$OUTPUT_DIR/$filename.json"
    split -l $PARTITION_LINECOUNT "$OUTPUT_DIR/$filename.json" "$OUTPUT_DIR/$filename.json.split."
done
