import requests
import datetime

try:
    # Try to import the local env.py file
    from splash_nba.util.env import youtube_api_key
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import youtube_api_key
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")

def search_youtube_highlights(api_key, team_one, team_two, date):
    # YouTube API endpoint for search
    YOUTUBE_API_SEARCH_URL = 'https://www.googleapis.com/youtube/v3/search'

    # Format the query with teams and date
    query = f"{team_one} vs {team_two} highlights"

    # NBA's official YouTube channel ID
    nba_channel_id = "UCWJ2lWNubArHWmf3FIHbfcQ"

    # Prepare the request parameters
    params = {
        'part': 'snippet',
        'q': query,
        'key': api_key,
        'channelId': nba_channel_id,
        'type': 'video',
        'maxResults': 5,  # You can change this to return more results
        'order': 'relevance',  # Sort results by relevance
        'publishedAfter': f"{date}T00:00:00Z",  # Search for videos published after today
        'publishedBefore': f"{date}T23:59:59Z",  # Ensure it's within today's date
    }

    # Make the API request
    response = requests.get(YOUTUBE_API_SEARCH_URL, params=params)

    if response.status_code == 200:
        data = response.json()
        if 'items' in data:
            # Return the first video's ID, title, and channel (publisher) if available
            videos = [
                (item['id']['videoId'], item['snippet']['title'], item['snippet']['channelTitle'])
                for item in data['items']
                if item['id']['kind'] == 'youtube#video'
            ]
            if len(videos) > 0:
                if len(videos[0]) > 0:
                    return videos[0][0]
                else:
                    return 'No highlights found'
            else:
                return 'No highlights found'
        else:
            return None
    else:
        raise Exception(f"API request failed with status code {response.status_code}")


if __name__ == '__main__':
    # Set your teams
    team_one = "Boston Celtics"
    team_two = "Denver Nuggets"

    # Get today's date in the format YYYY-MM-DD
    today = datetime.datetime.now().strftime('%Y-%m-%d')

    # Search for highlights
    results = search_youtube_highlights(youtube_api_key, team_one, team_two, today)

    if results:
        print(results)
        #print("Top YouTube highlight results:")
        #for video_id in results:
            #print(f"Title: {title}")
            #print(f"Channel: {channel}")
            #print(f"URL: https://www.youtube.com/watch?v={video_id}\n")
    else:
        print("No highlights found for today.")