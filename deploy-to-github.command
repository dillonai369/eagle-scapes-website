#!/bin/bash
# Eagle Scapes — Direct deploy to Vercel (no GitHub auth, no PAT, no fuss)
# This uses Vercel CLI which authenticates via a browser pop-up — way easier.

cd "$(dirname "$0")"

clear
echo "╔════════════════════════════════════════════════╗"
echo "║  🦅  Eagle Scapes — Direct Vercel Deploy       ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# --- Cleanup ---
echo "🧹  Cleaning up..."
rm -f video/hero.mp4 2>/dev/null
rm -rf __pycache__ 2>/dev/null
rm -f _build*.py 2>/dev/null
rm -rf .git 2>/dev/null
echo "    ✓ Done"
echo ""

# --- Check for Node.js / npm ---
if ! command -v npx &> /dev/null; then
  echo "❌  Node.js / npm is not installed on this Mac."
  echo "    Install it from https://nodejs.org (LTS version), then run this script again."
  echo ""
  echo "Press any key to close..."
  read -n 1 -s
  exit 1
fi

NODE_VER=$(node --version 2>/dev/null)
echo "✓  Node.js detected: $NODE_VER"
echo ""

# --- Vercel project config ---
mkdir -p .vercel
# Tell Vercel this is a static site (no build command)
cat > vercel.json <<'EOF'
{
  "cleanUrls": true,
  "trailingSlash": false
}
EOF

# --- Deploy ---
echo "🚀  Starting Vercel deployment..."
echo ""
echo "    First time? A browser window will pop open asking you to log in."
echo "    After that, deploy will run automatically and print the live URL."
echo ""
echo "──────────────────────────────────────────────────"
echo ""

npx --yes vercel@latest deploy --prod --yes --name eagle-scapes-website

DEPLOY_STATUS=$?

echo ""
echo "──────────────────────────────────────────────────"
echo ""

if [ $DEPLOY_STATUS -eq 0 ]; then
  echo "╔════════════════════════════════════════════════╗"
  echo "║  ✅  Deployed!                                 ║"
  echo "╚════════════════════════════════════════════════╝"
  echo ""
  echo "Switch back to Claude — I'll wire up the custom domain"
  echo "(eaglescapes.studio7.select) and the Spaceship DNS now."
else
  echo "❌  Something went wrong. Tell Claude what the error said."
fi

echo ""
echo "Press any key to close this window..."
read -n 1 -s
