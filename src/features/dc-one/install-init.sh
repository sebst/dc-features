#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

readonly name='dc-init'

cp shoreman.sh /var/devcontainer.com/shoreman
chmod +x /var/devcontainer.com/shoreman

cp entrypoint.sh /var/devcontainer.com/entrypoint
chmod +x /var/devcontainer.com/entrypoint

printf '=== [Success] Feature "%s" installed.\n' \
  "${name}"
