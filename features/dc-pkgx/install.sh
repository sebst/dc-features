#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

# readonly TARGETARCH="$(dpkg --print-architecture)"
# export DEBIAN_FRONTEND='noninteractive'


# if ! [[ "${VERSION:-}" =~ ^(latest|[0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
#   >&2 printf '=== [ERROR] Option "version" (value: "%s") is not "latest" or valid semantic version format "X.Y.Z" !\n' \
#     "${VERSION}"
#   exit 1
# fi

declare -a requiredAptPackagesMissing=()

# if ! [ -r '/etc/ssl/certs/ca-certificates.crt' ]; then
#   requiredAptPackagesMissing+=('ca-certificates')
# fi

if ! command -v curl >/dev/null 2>&1; then
  requiredAptPackagesMissing+=('curl')
fi

# if ! command -v tar >/dev/null 2>&1; then
#   requiredAptPackagesMissing+=('tar')
# fi

# if ! command -v file >/dev/null 2>&1; then
#   requiredAptPackagesMissing+=('file')
# fi

# if [ "${VERSION}" == 'latest' ] && ! command -v jq >/dev/null 2>&1; then
#   requiredAptPackagesMissing+=('jq')
# fi

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

curl -fsS https://pkgx.sh | sh
