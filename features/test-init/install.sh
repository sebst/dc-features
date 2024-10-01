#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

echo "Installing entrypoint..."

install -v -m 755 ./entrypoint-test.sh /usr/local/bin/entrypoint-test
