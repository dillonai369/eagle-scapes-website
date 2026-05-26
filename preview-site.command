#!/bin/bash
# Eagle Scapes — Local Preview Launcher
# Double-click this file to start a local server and open the site in Chrome.

cd "$(dirname "$0")"
PORT=8765
echo "🌳 Eagle Scapes preview server starting..."
echo "📍 Site will open at: http://localhost:$PORT"
echo "🛑 To stop the server: close this window or press Ctrl+C"
echo ""

# Open Chrome to the local server after a tiny delay
( sleep 1 && open -a "Google Chrome" "http://localhost:$PORT/index.html" ) &

# Start a simple Python HTTP server (Python 3 is built into macOS)
python3 -m http.server $PORT
