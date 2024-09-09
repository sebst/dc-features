#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset
echo '==== DEVCONTAINER.COM ===='
echo '=== Feature: dc-s6-overlay'
echo '=========================='
cd "dc-s6-overlay"
./install.sh
