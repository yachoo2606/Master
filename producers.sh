#!/bin/bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <number of iterations>"
    exit 1
fi

# Number of times to run the command
num_iterations=$1

# Loop and run the Docker command
for (( i=1; i<=num_iterations; i++ )); do

    docker run --rm -d --network=masterNetwork \
    -e PEER_1_URL=http://172.20.0.2:9001/eureka/ \
    -e PRODUCER_ID=$i \
    -e LOGSTASH_DESTINATION_ONE=172.20.0.12:5000 \
    -e LOGSTASH_DESTINATION_TWO=172.20.0.13:5000 \
    -e LOGSTASH_DESTINATION_THREE=172.20.0.14:5000 \
    --name=PRODUCER_$i producer \

done
