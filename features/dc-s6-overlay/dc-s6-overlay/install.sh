#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

## source      | https://github.com/just-containers/s6-overlay
## releases    | https://github.com/just-containers/s6-overlay/releases
## example URL | https://github.com/just-containers/s6-overlay/releases/download/v3.1.5.0/s6-overlay-aarch64.tar.xz
## example URL | https://github.com/just-containers/s6-overlay/releases/download/v3.1.5.0/s6-overlay-x86_64.tar.xz

## [runtime dependencies]
## /usr/bin/unshare -> util-linux -> to start s6 (/init) from a script (not PID 0)
## /usr/bin/perl    -> perl-base  -> to handle SIGKILL and SIGTERM in entrypoint
## [setup dependencies]
## /usr/bin/curl     -> curl -> to download archive(s)
## /etc/ssl/certs/ca-certificates.crt -> trusted root certs, required by curl for HTTPS URLs
## /usr/bin/tar      -> tar -> to extract
## /usr/bin/xz       -> xz-utils -> to extract

readonly githubRepository='just-containers/s6-overlay'
readonly name="${githubRepository##*/}"

if ! [[ "${VERSION:-}" =~ ^(latest|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
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

if ! command -v xz >/dev/null 2>&1; then
  requiredAptPackagesMissing+=('xz-utils')
fi

if ! command -v unshare >/dev/null 2>&1; then
  requiredAptPackagesMissing+=('util-li')
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

  printf '=== Install required apt packages:\n'
  printf '=== * \n' \
    "${requiredAptPackagesMissing[@]}"
  apt-get install \
    --option 'Debug::pkgProblemResolver=true' \
    --option 'Debug::pkgAcquire::Worker=1' \
    --yes \
    --no-install-recommends \
    --no-install-suggests \
        "${requiredAptPackagesMissing[@]}"

  printf '=== Clear apt package lists folder\n'
    rm -rf \
    /var/lib/apt/lists/*
fi

if [ "${VERSION}" == 'latest' ] || [ -z "${VERSION}" ]; then
  readonly latestVersionGitHubUrl="https://api.github.com/repos/${githubRepository}/releases/latest"
  readonly latestVersionResolvedFromGitHub=$(
    curl \
      --silent \
        "${latestVersionGitHubUrl}" \
    | jq \
      -r '.tag_name | capture("(?<version>([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+))").version'
  )

  if [ -z "${latestVersionResolvedFromGitHub}" ]; then
    >&2 printf '=== [ERROR] Failed to retrieve latest version from URL "%s"!\n' \
      "${latestVersionGitHubUrl}"
    exit 1
  fi

  VERSION="${latestVersionResolvedFromGitHub}"
fi

readonly version="${VERSION:?}"
readonly architecture=$(
  case "$(dpkg --print-architecture)" in \
    'arm64') \
      echo -n 'aarch64';; \
    'amd64') \
      echo -n 'x86_64';; \
    esac
)

declare -ra downloadUrls=(
  "https://github.com/just-containers/s6-overlay/releases/download/v${version}/s6-overlay-noarch.tar.xz"
  "https://github.com/just-containers/s6-overlay/releases/download/v${version}/s6-overlay-${architecture}.tar.xz"
)

for downloadUrl in "${downloadUrls[@]}"; do
  filename="${downloadUrl##*/}"
  targetPath="/tmp/${filename}"
  printf '=== Download "%s" to "%s"\n' \
      "${downloadUrl}" \
      "${targetPath}"
  curl \
    --silent \
    --location \
    --fail \
    --show-error \
    --output "${targetPath}" \
      "${downloadUrl}"
  printf '=== Extract "%s" to "/"\n' \
      "${targetPath}"
  tar \
    -C / \
    -Jxp \
    -f "${targetPath}"
  unset filename targetPath
done

readonly entrypoint='/usr/local/share/entrypoint.bash'
printf '=== Copy entrypoint to "%s"\n' \
  "${entrypoint}"
cp -f ./entrypoint.bash "${entrypoint}"
printf '=== Make entrypoint "%s" executable\n' \
  "${entrypoint}"
chmod +x "${entrypoint}"

printf '=== [Success] Feature "%s" installed.\n\n' \
  "${name}"
