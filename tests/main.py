import json
import time
import random
import requests
import asyncio
import concurrent.futures
import plotly.graph_objects as go
from matplotlib import pyplot as plt
from tqdm import tqdm

# Global arrays to store request times, requests, and responses
request_times = []
request_responses = []


def loadJSON(file_path):
    with open(file_path, 'r') as f:
        return json.load(f)


def sendRequest(i, url, json_data):
    sampled_data = random.sample(json_data, random.randint(1, 10))
    for element in sampled_data:
        element['amount'] = random.randint(1, 16)

    # Measure the time taken for the request
    start_time = time.time()
    response = requests.post(f"http://{url}/proposal", json=sampled_data)
    end_time = time.time()

    # Calculate and save the time taken
    request_time = end_time - start_time
    request_times.append(request_time)

    # Save the request and response
    request_responses.append({
        "request_number": i + 1,
        "sampled_data": sampled_data,
        "sampled_count": len(sampled_data),
        "response_status": response.status_code,
        "response_data": response.text,
        "request_time": request_time
    })

    print(f"Request {i + 1} response status: {response.status_code}, time taken: {request_time:.4f} seconds")
    return response


async def sendRequestAsync(executor, i, url, json_data, semaphore):
    async with semaphore:
        loop = asyncio.get_event_loop()
        start_time = time.time()
        response = await loop.run_in_executor(executor, sendRequest, i, url, json_data)
        end_time = time.time()
        print(f"Request {i + 1} async overhead time: {end_time - start_time:.4f} seconds")
        return response


async def main(workers_url, countOfRequests):
    json_data = loadJSON("products.json")
    semaphore = asyncio.Semaphore(countOfRequests)  # Limit to 10 concurrent requests
    executor = concurrent.futures.ThreadPoolExecutor(max_workers=countOfRequests)

    tasks = []
    for i in tqdm(range(countOfRequests)):
        url = random.choice(workers_url)
        task = sendRequestAsync(executor, i, url, json_data, semaphore)
        tasks.append(task)
    await asyncio.gather(*tasks)

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
    asyncio.run(main(["localhost:12001", "localhost:12002"], 100))
