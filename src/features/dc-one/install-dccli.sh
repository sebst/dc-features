#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

readonly TARGETARCH="$(dpkg --print-architecture)"
export DEBIAN_FRONTEND='noninteractive'

readonly name='dc-ccli'
readonly githubRepository='sebst/dc-ccli'
readonly binaryName="${name}"
readonly binaryPathInArchive="${binaryName}"
readonly binaryTargetFolder='/usr/local/bin'
readonly binaryTargetPath="${binaryTargetFolder}/${binaryPathInArchive}"
readonly versionArgument='--version'

if ! [[ "${VERSION:-}" =~ ^(latest|[0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  >&2 printf '=== [ERROR] Option "version" (value: "%s") is not "latest" or valid semantic version format "X.Y.Z" !\n' \
    "${VERSION}"
  exit 1
fi

declare -a requiredAptPackagesMissing=()

if ! [ -r '/etc/ssl/certs/ca-certificates.crt' ]; then
  requiredAptPackagesMissing+=('ca-certificates')
fi

if ! command -v curl >/dev/null 2>&1; then
  requiredAptPackagesMissing+=('curl')
fi

if ! command -v tar >/dev/null 2>&1; then
  requiredAptPackagesMissing+=('tar')
fi

if ! command -v file >/dev/null 2>&1; then
  requiredAptPackagesMissing+=('file')
fi

if [ "${VERSION}" == 'latest' ] && ! command -v jq >/dev/null 2>&1; then
  requiredAptPackagesMissing+=('jq')
fi

declare -i requiredAptPackagesMissingCount=${#requiredAptPackagesMissing[@]}
printf '=== Need to install %s required apt packages\n' \
  "${requiredAptPackagesMissingCount}"

if [ $requiredAptPackagesMissingCount -gt 0 ]; then
  printf '=== Run apt-get update\n'
  apt-get update

  printf '=== Install required apt packages "ca-certificates", "curl" and "tar"\n'
  apt-get install \
    --option 'Debug::pkgProblemResolver=true' \
    --option 'Debug::pkgAcquire::Worker=1' \
    --yes \
    --no-install-recommends \
    --no-install-suggests \
        "${requiredAptPackagesMissing[@]}"
fi

if [ "${VERSION}" == 'latest' ] || [ -z "${VERSION}" ]; then
  printf '=== Given option "version" is "latest" or empty string ""\n'

  readonly latestVersionGitHubUrl="https://api.github.com/repos/${githubRepository}/releases/latest"
  >&2 printf '=== Get version of latest release from GitHub API at "%s"\n' \
    "${latestVersionGitHubUrl}"
  readonly latestVersionResolvedFromGitHub=$(
    curl \
      --silent \
      --fail \
      --show-error \
       -H "${GITHUB_TOKEN:+"Authorization: token "}${GITHUB_TOKEN:-}" \
        "${latestVersionGitHubUrl}" \
    | jq -r '.tag_name | capture("(?<version>([0-9]+\\.[0-9]+\\.[0-9]+))").version' \
    || true
  )

  if [ -z "${latestVersionResolvedFromGitHub}" ]; then
    >&2 printf '=== [ERROR] Failed to retrieve latest version from URL "%s"!\n' \
      "${latestVersionGitHubUrl}"
    exit 1
  fi

  VERSION="${latestVersionResolvedFromGitHub}"
fi

readonly version="${VERSION:?}"
releaseArch="$(dpkg --print-architecture)"
if [ "${releaseArch}" == "arm64" ]; then
  releaseArch="arm64"
else
  releaseArch="x86_64"
fi
readonly downloadUrl="https://github.com/${githubRepository}/releases/download/v${version}/${name}_Linux_${releaseArch}.tar.gz"


printf '=== Test if archive download URL "%s" is valid\n' \
  "${downloadUrl}"
curl \
  --silent \
  --location \
  --head \
  --fail \
  --fail-early \
  --show-error \
  --output '/dev/null' \
    "${downloadUrl}"

printf '=== Download & extract "%s" binary version "%s" from URL "%s" \n' \
  "${binaryName}" \
  "${version}" \
  "${downloadUrl}"
curl \
  -sL \
  -o- \
    "${downloadUrl}" \
  | tar \
    -xz \
    -f- \
    -C "${binaryTargetFolder}" \
      "${binaryPathInArchive}"

printf '=== Set 755 permissions for downloaded binary at "%s"\n' \
  "${binaryTargetPath}"
chmod 755 \
  "${binaryTargetPath}"

printf '=== Clear apt package lists folder\n'
rm -rf \
  /var/lib/apt/lists/*

printf '=== Active "%s" is now "%s"\n' \
  "${binaryName}" \
  "$(which "${binaryName}")"

"${binaryName}" "${versionArgument}"

printf '=== [Success] Feature "%s" installed.\n' \
  "${name}"
