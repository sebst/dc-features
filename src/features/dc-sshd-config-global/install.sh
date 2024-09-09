#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset -o allexport

readonly featureName='sshd-config-global'

readonly userName="${USER_NAME:-root}"

readonly userHomeDirectory=$( getent passwd "${userName}" | cut -d: -f6 )

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

printf '=== Installing privilege separation directory\n'
install -d -m 0755 -o root -g root /run/sshd

printf '=== Copy authorized key file(s)\n'
rsync -a --stats --chown="${userName}" --chmod=D2700,F600 --ignore-times \
  "${installationContext}/_user/.ssh/" \
  "/${userHomeDirectory}/.ssh/"

printf '=== Copy config file(s)\n'
rsync -a --stats --chown="${userName}" --chmod=D2700,F600 --ignore-times \
  "${installationContext}/etc/ssh/" \
  "/etc/ssh/"

printf '=== [Success] Feature "%s" installed.\n\n' \
  "${featureName}"
