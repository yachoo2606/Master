import json
import time
import random
import asyncio
import aiohttp
import plotly.graph_objects as go
from matplotlib import pyplot as plt
from tqdm import tqdm

# Global arrays to store request times, requests, and responses
request_times = []
request_responses = []


def loadJSON(file_path):
    with open(file_path, 'r') as f:
        return json.load(f)


async def sendRequest(session, i, url, json_data):
    sampled_data = random.sample(json_data, random.randint(1, 10))
    for element in sampled_data:
        element['amount'] = random.randint(1, 16)

    # Measure the time taken for the request
    start_time = time.time()
    async with session.post(f"http://{url}/proposal", json=sampled_data) as response:
        end_time = time.time()

        # Calculate and save the time taken
        request_time = end_time - start_time
        request_times.append(request_time)

        # Save the request and response
        response_data = await response.text()
        request_responses.append({
            "request_number": i + 1,
            "sampled_data": sampled_data,
            "sampled_count": len(sampled_data),
            "response_status": response.status,
            "response_data": response_data,
            "request_time": request_time
        })

        print(f"Request {i + 1} response status: {response.status}, time taken: {request_time:.4f} seconds")


async def main(workers_url, countOfRequests):
    json_data = loadJSON("products.json")

    async with aiohttp.ClientSession() as session:
        tasks = []
        for i in tqdm(range(countOfRequests)):
            url = random.choice(workers_url)
            task = asyncio.create_task(sendRequest(session, i, url, json_data))
            tasks.append(task)
        await asyncio.gather(*tasks)

    # Print the global array of request times
    print("Request times:", request_times)

    # Print requests and their responses
    for request_response in request_responses:
        print(f"Request {request_response['request_number']}:")
        print(f"  Sampled data count: {request_response['sampled_count']}")
        print(f"  Sampled data: {request_response['sampled_data']}")
        print(f"  Response status: {request_response['response_status']}")
        print(f"  Response data: {request_response['response_data']}")
        print(f"  Time taken: {request_response['request_time']:.4f} seconds\n")

    plot_request_times()
    plot_request_times_plt()


def plot_request_times_plt():
    plt.figure(figsize=(12, 6))
    plt.bar(range(len(request_times)), request_times, color='blue')
    plt.xlabel('Request Number')
    plt.ylabel('Time (seconds)')
    plt.title('Time Taken for Each Request')
    plt.show()


def plot_request_times():
    # Create a bar chart using plotly
    fig = go.Figure()

    fig.add_trace(go.Bar(
        x=list(range(1, len(request_times) + 1)),
        y=request_times,
        text=[
            f"Request {r['request_number']}<br>Sampled data count: {r['sampled_count']}<br>Response status: {r['response_status']}<br>Time taken: {r['request_time']:.4f} seconds"
            for r in request_responses],
        hoverinfo='text',
        marker=dict(color='blue')
    ))

    fig.update_layout(
        title='Time Taken for Each Request',
        xaxis_title='Request Number',
        yaxis_title='Time (seconds)',
        xaxis=dict(tickmode='linear')
    )

    fig.show()


if __name__ == '__main__':
    asyncio.run(main(["localhost:12001", "localhost:12002"], 1000))
