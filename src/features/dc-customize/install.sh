#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

echo "=== Installing Devcontainer Customization Helper ==="

readonly dcApiKey="${API_KEY:-}"
readonly dcProfileId="${PROFILE_ID:-}"

# exit 1 if not set
if [ -z "$dcApiKey" ]; then
    echo "Api key not set"
    exit 1
fi

if [ -z "$dcProfileId" ]; then
    echo "Profile Id not set"
    exit 1
fi

rm -rf /usr/local/bin/dc-customize
sed "s/API_KEY/${dcApiKey}/g; s/PROFILE_ID/${dcProfileId}/g" ./dc-customize >/usr/local/bin/dc-customize
chmod +x /usr/local/bin/dc-customize

echo " (*) Done"
