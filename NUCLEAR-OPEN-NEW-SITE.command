#!/bin/bash
# NUCLEAR option: open Chrome with a brand-new throwaway profile.
# Bypasses ALL caches: history, cookies, HTTP cache, service workers, DNS cache.
# If THIS doesn't show the new site, the problem isn't Chrome — it's deeper.

clear
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  🦅  Eagle Scapes — Nuclear Cache Bypass                 ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# 1) Show what /etc/hosts currently contains for our domain
echo "📋  Step 1: Checking /etc/hosts for eaglescapeslawncare entries..."
HOSTS_MATCH=$(grep -i "eaglescapeslawncare" /etc/hosts 2>/dev/null)
if [ -z "$HOSTS_MATCH" ]; then
  echo "   ⚠  No entries found. Adding them now (will prompt for password)..."
  echo "" | sudo tee -a /etc/hosts >/dev/null
  echo "# Eagle Scapes Vercel ($(date +%Y-%m-%d))" | sudo tee -a /etc/hosts >/dev/null
  echo "216.150.1.1  eaglescapeslawncare.com" | sudo tee -a /etc/hosts >/dev/null
  echo "216.150.1.1  www.eaglescapeslawncare.com" | sudo tee -a /etc/hosts >/dev/null
  echo "   ✓ Entries added."
else
  echo "   ✓ Found entries:"
  echo "$HOSTS_MATCH" | sed 's/^/      /'
fi
echo ""

# 2) Flush DNS
echo "🧹  Step 2: Flushing DNS cache..."
sudo dscacheutil -flushcache 2>/dev/null
sudo killall -HUP mDNSResponder 2>/dev/null
echo "   ✓ Flushed."
echo ""

# 3) Verify DNS resolution from THIS machine
echo "🔍  Step 3: Verifying what your Mac now resolves to..."
RESOLVED=$(dscacheutil -q host -a name eaglescapeslawncare.com 2>/dev/null | grep ip_address | head -1 | awk '{print $2}')
if [ "$RESOLVED" = "216.150.1.1" ]; then
  echo "   ✓ Your Mac resolves eaglescapeslawncare.com → 216.150.1.1 (Vercel) ✅"
else
  echo "   ⚠  Your Mac resolves to: $RESOLVED  (should be 216.150.1.1)"
fi
echo ""

# 4) Verify Vercel is actually serving the new site at that IP
echo "🌐  Step 4: Testing if Vercel responds correctly..."
RESPONSE=$(curl -sI -L --max-time 10 -H "Host: www.eaglescapeslawncare.com" \
  https://www.eaglescapeslawncare.com/ 2>&1 | head -1)
echo "   $RESPONSE"
echo ""

# 5) Force-quit Chrome
echo "🛑  Step 5: Force-quitting all Chrome processes..."
pkill -9 -i chrome 2>/dev/null
pkill -9 -i "Google Chrome" 2>/dev/null
sleep 2
echo "   ✓ Chrome processes killed."
echo ""

# 6) Wipe any throwaway profile from last run
rm -rf /tmp/eaglescapes_fresh_chrome 2>/dev/null

# 7) Launch Chrome with a BRAND NEW PROFILE — zero history, zero cache, zero everything
echo "🚀  Step 6: Launching Chrome with a fresh profile (no cache, no cookies)..."
open -na "Google Chrome" --args \
  --user-data-dir=/tmp/eaglescapes_fresh_chrome \
  --no-default-browser-check \
  --no-first-run \
  --disable-features=DnsOverHttps \
  "https://www.eaglescapeslawncare.com/?nuclear=$(date +%s)"

echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  Chrome is opening with a brand-new, cache-free profile."
echo "  This bypasses ALL caches — DNS, HTTP, service worker, cookies."
echo ""
echo "  If the new site shows up → original Chrome profile has stale"
echo "    cache. Clear it via chrome://settings/clearBrowserData"
echo "  If still old site → screenshot what's on screen and tell me."
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Press any key to close this window..."
read -n 1 -s
