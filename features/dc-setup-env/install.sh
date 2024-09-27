#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

readonly TARGETARCH="$(dpkg --print-architecture)"
export DEBIAN_FRONTEND='noninteractive'

readonly name='dc-setup-env'
readonly configFileUrl=${URL}

declare -a requiredAptPackagesMissing=()

if ! [ -r '/etc/ssl/certs/ca-certificates.crt' ]; then
  requiredAptPackagesMissing+=('ca-certificates')
fi

if ! command -v curl >/dev/null 2>&1; then
  requiredAptPackagesMissing+=('curl')
fi

declare -i requiredAptPackagesMissingCount=${#requiredAptPackagesMissing[@]}
printf '=== Need to install %s required apt packages\n' \
  "${requiredAptPackagesMissingCount}"

if [ $requiredAptPackagesMissingCount -gt 0 ]; then
  printf '=== Run apt-get update\n'
  apt-get update

  printf '=== Install required apt packages "ca-certificates", "curl" and "tar"\n'
  apt-get install \
    --option 'Debug::pkgProblemResolver=true' \
    --option 'Debug::pkgAcquire::Worker=1' \
    --yes \
    --no-install-recommends \
    --no-install-suggests \
        "${requiredAptPackagesMissing[@]}"
fi

# Create the directories
mkdir /var/devcontainer.com
chmod a+rw /var/devcontainer.com
touch /var/devcontainer.com/services.proc
chmod a+rw /var/devcontainer.com/services.proc
touch /var/devcontainer.com/services.env
chmod a+rw /var/devcontainer.com/services.env
# touch /var/devcontainer.com/config.json
# chmod a+rw /var/devcontainer.com/config.json


# Install pkgx.sh
# TODO: Needs to be done by dc-ccli
curl -Ssf https://pkgx.sh | sh

# Get the config file
curl -SsfL "${configFileUrl}" > "/var/devcontainer.com/config.json"

# Ensure the config file is there
ls /var/devcontainer.com | grep config.json

# Apply the config file
dc-ccli config apply "/var/devcontainer.com/config.json"


printf '=== [Success] Feature "%s" installed.\n' \
  "${name}"
