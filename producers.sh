#!/bin/bash

# Check if the necessary arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <first producer id> <number of producers>"
    exit 1
fi

# First producer ID and number of producers to run
first_producer_id=$1
num_producers=$2

# Loop and run the Docker command
for (( i=first_producer_id; i<first_producer_id+num_producers; i++ )); do

    docker run --rm -d --network=masterNetwork \
    -e PEER_1_URL=http://172.20.0.2:9001/eureka/ \
    -e PRODUCER_ID=$i \
    -e LOGSTASH_DESTINATION_ONE=172.20.0.12:5000 \
    -e LOGSTASH_DESTINATION_TWO=172.20.0.13:5000 \
    -e LOGSTASH_DESTINATION_THREE=172.20.0.14:5000 \
    --name=PRODUCER_$i producer \

done
