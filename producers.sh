#!/bin/bash

# Check if the necessary arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <first producer id> <number of producers>"
    exit 1
fi

# First producer ID and number of producers to run
first_producer_id=$1
num_producers=$2

# Function to check if the Docker image exists and build it if not
ensure_docker_image() {
    if [ -z "$(docker images -q producer:latest 2> /dev/null)" ]; then
        echo "'producer:latest' image not found. Building image..."
        if ! docker build Producer -t producer:latest --no-cache; then
            echo "Error building Docker image 'producer:latest'. Exiting."
            exit 1
        fi
    fi
}

# Ensure the Docker image is available
ensure_docker_image

# Loop and run the Docker command
for (( i=first_producer_id; i<first_producer_id+num_producers; i++ )); do

    docker run --rm -d --network=masterNetwork \
    -e PEER_1_URL=http://172.20.0.2:9001/eureka/,http://172.20.0.3:9002/eureka/,http://172.20.0.4:9003/eureka/ \
    -e PRODUCER_ID=$i \
    -e LOGSTASH_DESTINATION_ONE=172.20.0.12:5000 \
    -e LOGSTASH_DESTINATION_TWO=172.20.0.13:5000 \
    -e LOGSTASH_DESTINATION_THREE=172.20.0.14:5000 \
    -e NUMBER_OF_PRODUCTS=10 \
    -e PORT=10000 \
    -p $((10000+$i)):10000 \
    --name=PRODUCER_$i producer:latest

done
