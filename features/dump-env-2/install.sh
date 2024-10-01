#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset


echo "Dumping environment variables..."
env > /tmp/feature-dumpenv-2-env.txt
