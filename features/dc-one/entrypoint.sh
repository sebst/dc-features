#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

echo '==== DEVCONTAINER.COM ===='
echo '=== Feature: dc-one'
echo '=========================='
cd "dc-one"
./install.sh
