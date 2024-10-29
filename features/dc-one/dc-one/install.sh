#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

readonly name='dc-init'


./install-dccli.sh
./install-setup-env.sh
./install-init.sh

printf '=== [Success] Feature "%s" installed.\n' \
  "${name}"
