#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

echo "=== Installing Cloudflare Warp CLI ==="

./install.checktos.sh

./install.debian.sh

./install.connect.sh

cp bin/war-cli-test /usr/local/bin/warp-cli
chmod 755 /usr/local/bin/warp-cli

echo "=== Cloudflare Warp CLI installed ==="
