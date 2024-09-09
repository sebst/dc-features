#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

# note: only install rsync if not already vailable
if ! command -v rsync >/dev/null 2>&1; then
  apt-get update
  apt-get install -qq \
    -o 'Debug::pkgProblemResolver=true' \
    -o 'Debug::pkgAcquire::Worker=1' \
    --no-install-recommends \
    --no-install-suggests \
      rsync
fi

# note: $installationContext equals "dirname ${BASH_SOURCE[0]}" aka. the absolute path of this script's parent folder
readonly installationContext="${BASH_SOURCE[0]%/*}"

rsync -a -v --ignore-times \
  "${installationContext}/s6-rc.d/" \
  /etc/s6-overlay/s6-rc.d/
