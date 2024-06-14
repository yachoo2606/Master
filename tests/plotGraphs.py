import json
import matplotlib.pyplot as plt
import plotly.graph_objects as go

# Load the JSON data from the file
with open('results_102.json', 'r') as file:
    data = json.load(file)

# Extract request times in milliseconds
request_times = [float(req['request_time'].replace('ms', '')) for req in data['requests']]
request_responses = data['requests']

# Adding response status to the requests for plotting
for req in request_responses:
    req['response_status'] = 200  # Assuming 200 OK for all responses as the status is not provided


# Function to plot request times using matplotlib
def plot_request_times_plt():
    plt.figure(figsize=(12, 6))
    plt.bar(range(1, len(request_times) + 1), request_times, color='blue')
    plt.xlabel('Request Number')
    plt.ylabel('Time (milliseconds)')
    plt.title('Time Taken for Each Request')
    plt.show()


# Function to plot request times using plotly
def plot_request_times():
    # Create a bar chart using plotly
    fig = go.Figure()

    fig.add_trace(go.Bar(
        x=list(range(1, len(request_times) + 1)),
        y=request_times,
        text=[
            f"Request {r['request_number']}<br>Sampled data count: {r['sampled_count']}<br>Response status: {r['response_status']}<br>Time taken: {r['request_time']}"
            for r in request_responses],
        hoverinfo='text',
        marker=dict(color='blue')
    ))

    fig.update_layout(
        title='Time Taken for Each Request',
        xaxis_title='Request Number',
        yaxis_title='Time (milliseconds)',
        xaxis=dict(tickmode='linear')
    )

    fig.show()


# Plot using matplotlib
plot_request_times_plt()

# Plot using plotly
plot_request_times()
