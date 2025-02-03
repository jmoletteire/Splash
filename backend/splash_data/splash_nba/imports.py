try:
    # Try to import the local env.py file
    from splash_nba.util.env import URI, PREV_SEASON, CURR_SEASON, NEXT_SEASON, CURR_SEASON_TYPE, NEWS_API_KEY, YOUTUBE_API_KEY
    from splash_nba.util.mongo_connect import get_mongo_collection
    PROXY = None
except ImportError:
    # Fallback to the remote env.py path
    import sys
    import os

    env_path = "/home/ubuntu"
    if env_path not in sys.path:
        sys.path.insert(0, env_path)  # Add /home/ubuntu to the module search path

    try:
        from env import PROXY, URI, PREV_SEASON, CURR_SEASON, NEXT_SEASON, CURR_SEASON_TYPE, NEWS_API_KEY, YOUTUBE_API_KEY
    except ImportError:
        raise ImportError("env.py could not be found locally or at /home/ubuntu.")

    try:
        from mongo_connect import get_mongo_collection
    except ImportError:
        raise ImportError("mongo_connect.py could not be found locally or at /home/ubuntu.")