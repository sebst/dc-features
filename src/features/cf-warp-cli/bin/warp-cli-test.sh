#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

echo "Checking WARP connection..."
curl -s https://www.cloudflare.com/cdn-cgi/trace | grep "warp=on"
echo "Done."