#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset -o allexport

readonly featureName='sshd'

declare -a requiredAptPackagesMissing=()

if ! command -v sshd >/dev/null 2>&1; then
  requiredAptPackagesMissing+=('openssh-server')
  requiredAptPackagesMissing+=('openssh-sftp-server')
fi

declare -i requiredAptPackagesMissingCount=${#requiredAptPackagesMissing[@]}
printf '=== Need to install %s required apt packages\n' \
  "${requiredAptPackagesMissingCount}"

if [ $requiredAptPackagesMissingCount -gt 0 ]; then
  printf '=== Run apt-get update\n'
  apt-get update

  printf '=== Install required apt packages:\n'
  printf '=== * \n' \
    "${requiredAptPackagesMissing[@]}"
  apt-get install \
    --option 'Debug::pkgProblemResolver=true' \
    --option 'Debug::pkgAcquire::Worker=1' \
    --yes \
    --no-install-recommends \
    --no-install-suggests \
        "${requiredAptPackagesMissing[@]}"

  printf '=== Clear apt package lists folder\n'
    rm -rf \
    /var/lib/apt/lists/*
fi

printf '=== [Success] Feature "%s" installed.\n\n' \
  "${featureName}"
