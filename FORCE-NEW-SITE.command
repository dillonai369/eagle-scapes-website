#!/bin/bash
# Force your Mac to see the new Vercel site immediately, bypassing all DNS caches.
# This adds 2 entries to /etc/hosts that point eaglescapeslawncare.com directly
# at Vercel's IP — your machine will never ask DNS again for these domains.
#
# Once DNS fully propagates globally (within ~4 hours), you can revert this file
# by re-running it with the REVERT flag, but it's harmless to leave in place too.

set -e

echo ""
echo "════════════════════════════════════════════════════════"
echo "  🦅  Force Eagle Scapes New Site (Bypass DNS Cache)"
echo "════════════════════════════════════════════════════════"
echo ""
echo "This will:"
echo "  1. Add entries to /etc/hosts pointing eaglescapeslawncare.com"
echo "     directly to Vercel's IP (216.150.1.1)"
echo "  2. Flush your Mac's DNS cache"
echo "  3. Kill all Chrome processes (you'll need to reopen Chrome)"
echo ""
echo "You'll be prompted for your Mac login password (it's silent — keep typing)."
echo ""
read -n 1 -s -r -p "Press any key to continue, or close this window to cancel..."
echo ""
echo ""

# 1) Remove any existing eaglescapeslawncare entries we previously added
sudo sed -i.bak '/eaglescapeslawncare.com/d' /etc/hosts 2>/dev/null

# 2) Append fresh entries pointing to Vercel
echo "📝  Adding Vercel IPs to /etc/hosts..."
echo "" | sudo tee -a /etc/hosts >/dev/null
echo "# Eagle Scapes - force new Vercel site (added $(date +%Y-%m-%d))" | sudo tee -a /etc/hosts >/dev/null
echo "216.150.1.1  eaglescapeslawncare.com" | sudo tee -a /etc/hosts >/dev/null
echo "216.150.1.1  www.eaglescapeslawncare.com" | sudo tee -a /etc/hosts >/dev/null

# 3) Flush DNS cache aggressively
echo "🧹  Flushing DNS cache..."
sudo dscacheutil -flushcache 2>/dev/null
sudo killall -HUP mDNSResponder 2>/dev/null

# 4) Quit Chrome so it can't serve a cached page
echo "🛑  Quitting Chrome (will reopen fresh)..."
osascript -e 'tell application "Google Chrome" to quit' 2>/dev/null || true
sleep 2

# 5) Reopen Chrome directly at the new site
echo "🚀  Opening the new site in Chrome..."
open -a "Google Chrome" "https://www.eaglescapeslawncare.com/"

echo ""
echo "════════════════════════════════════════════════════════"
echo " ✅  Done. The new site should be loading in Chrome now."
echo "════════════════════════════════════════════════════════"
echo ""
echo " If Chrome still shows the old site, hit cmd+shift+R inside it"
echo " (hard refresh) — that bypasses Chrome's HTTP cache too."
echo ""
echo " Press any key to close this window..."
read -n 1 -s
