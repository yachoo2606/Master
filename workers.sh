#!/bin/bash

# Check if the necessary arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <first worker id> <number of workers>"
    exit 1
fi

# First producer ID and number of producers to run
first_worker_id=$1
num_workers=$2

# Function to check if the Docker image exists and build it if not
ensure_docker_image() {
    if [ -z "$(docker images -q worker:latest 2> /dev/null)" ]; then
        echo "'worker:latest' image not found. Building image..."
        if ! docker build Master-Protocol-Worker -t worker:latest --no-cache; then
            echo "Error building Docker image 'worker:latest'. Exiting."
            exit 1
        fi
    fi
}

# Ensure the Docker image is available
ensure_docker_image

# Loop and run the Docker command
for (( i=first_worker_id; i<first_worker_id+num_workers; i++ )); do

    docker run --rm -d --network=masterNetwork \
    -e PEER_1_URL=http://172.20.0.2:9001/eureka/,http://172.20.0.3:9002/eureka/,http://172.20.0.4:9003/eureka/ \
    -e WORKER_ID=$i \
    -e LOGSTASH_DESTINATION_ONE=172.20.0.12:5000 \
    -e LOGSTASH_DESTINATION_TWO=172.20.0.13:5000 \
    -e LOGSTASH_DESTINATION_THREE=172.20.0.14:5000 \
    --name=Worker-$i \
    -p $((12000+$i)):11000 \
    worker

done
