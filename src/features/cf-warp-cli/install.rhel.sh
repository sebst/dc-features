#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

echo "Setting up Cloudflare WARP..."
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo
sudo yum update && sudo yum install cloudflare-warp
