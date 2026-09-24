#!/usr/bin/env bash
# Build a clean dist/ and publish it to Cloudflare Pages.
#   SITE_URL=https://your-domain ./deploy.sh      (default: https://petalgram.pages.dev)
# Needs a Cloudflare login first:  npx wrangler login
set -euo pipefail
cd "$(dirname "$0")"
SITE_URL="${SITE_URL:-https://petalgram.pages.dev}"; SITE_URL="${SITE_URL%/}"
PROJECT="${PROJECT:-petalgram}"

rm -rf dist && mkdir -p dist/assets
cp index.html making-of.html flower.webp poster.png _headers dist/
cp assets/*.jpg dist/assets/

# social cards need absolute URLs
sed -i.bak \
  -e "s#content=\"poster.png\"#content=\"$SITE_URL/poster.png\"#g" \
  -e "s#<meta property=\"og:type\" content=\"website\">#<meta property=\"og:type\" content=\"website\">\n<meta property=\"og:url\" content=\"$SITE_URL/\">#" \
  -e "/social cards: set og:url/d" dist/index.html
sed -i.bak -e "s#content=\"assets/still-16x9.jpg\"#content=\"$SITE_URL/assets/still-16x9.jpg\"#g" dist/making-of.html
rm dist/*.bak

echo "Built dist/ for $SITE_URL"
npx --yes wrangler@4 pages deploy dist --project-name="$PROJECT" --branch=main
