#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

echo "=== Installing Devcontainer Customization Helper ==="

readonly dcApiKey="${API_KEY:-}"
readonly dcProjectId="${PROJECT_ID:-}"

# exit 1 if not set
if [ -z "$dcApiKey" ]; then
    echo "Api key not set"
    exit 1
fi

if [ -z "$dcProjectId" ]; then
    echo "Project Id not set"
    exit 1
fi

rm -rf /usr/local/bin/dc-project-setup
sed "s/API_KEY/${dcApiKey}/g; s/PROJECT_ID/${dcProjectId}/g" ./dc-project-setup >/usr/local/bin/dc-project-setup
chmod a+rx /usr/local/bin/dc-project-setup

echo " (*) Done"
