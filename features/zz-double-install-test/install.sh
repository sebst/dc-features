#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

readonly name='zz-double-install-test'
readonly executableName="${EXECNAME}"


readonly targetPath="/usr/local/bin/${executableName}"

echo "#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset" > "${targetPath}"
echo "echo 'Hello, World!'" >> "${targetPath}"
echo 'echo $0' >> "${targetPath}"
chmod +x "${targetPath}"

env > /tmp/env.txt


printf '=== [Success] Feature "%s" installed.\n' \
  "${name}"
