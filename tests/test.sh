#!/bin/bash

# Function to generate a random number between two values
randint() {
  local min=$1
  local max=$2
  echo $((RANDOM % (max - min + 1) + min))
}

# Function to send a POST request
send_request() {
  local url=$1
  local json_data=$2
  local request_number=$3
  local count_of_requests=$4

  # Sample the data
  sampled_data=$(echo "$json_data" | jq -c --argjson randAmt "$(randint 1 15)" --argjson randLimit "$(randint 1 10)" 'map(.amount |= $randAmt) | .[:$randLimit]')

  start_time=$(date +%s%3N) # Get start time in milliseconds
  response=$(curl -s -w "%{http_code}" -o /dev/null -X POST "$url/proposal" -H "Content-Type: application/json" -d "$sampled_data")
  end_time=$(date +%s%3N)   # Get end time in milliseconds

  # Calculate time taken
  time_taken=$((end_time - start_time))

  # Get response data
  response_data=$(curl -s -X POST "$url/proposal" -H "Content-Type: application/json" -d "$sampled_data")

  # Print the request details and time taken
  echo "Request $request_number response status: $response, time taken: ${time_taken}ms"

  # Create JSON object for the request result
  result=$(jq -n \
    --argjson request_number "$request_number" \
    --argjson sampled_data "$sampled_data" \
    --arg sampled_count "$(echo $sampled_data | jq length)" \
    --arg response_data "$response_data" \
    --arg request_time "${time_taken}ms" \
    '{request_number: $request_number, sampled_data: $sampled_data, sampled_count: $sampled_count, response_data: $response_data, request_time: $request_time}')

  # Append the result to the results array in the results file
  jq --argjson result "$result" '.requests += [$result]' "$result_file" > "tmp${count_of_requests}.json" && mv "tmp${count_of_requests}.json" "$result_file"
}

# Load JSON data from a file
json_file="products.json"
json_data=$(cat "$json_file")

# URLs and number of requests
workers_url=("http://localhost:12001" "http://localhost:12002")
count_of_requests=$1

# File to save results
result_file="results_${count_of_requests}.json"
echo '{"requests": []}' > "$result_file" # Initialize the JSON file with an empty array

# Sending requests
for ((i = 1; i <= count_of_requests; i++)); do
  url=${workers_url[$((RANDOM % ${#workers_url[@]}))]}
  send_request "$url" "$json_data" "$i" "$count_of_requests"
done

echo "All requests completed."
