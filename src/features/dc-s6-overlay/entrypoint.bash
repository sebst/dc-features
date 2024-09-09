#!/usr/bin/env -S bash --noprofile --norc -o errexit -o pipefail -o noclobber -o nounset

export PATH="${PATH}:/command"
mkdir -p /run/s6

# note: log start date for debugging purposes
echo "[entrypoint] Started at: $(date +'%Y-%m-%dT%H:%M:%S%:z')" | tee -a /var/run/entrypoint.log

if [ -n "${1:-}" ]; then
  printf '[entrypoint] ${1} is "%s"\n' "${1}"

  if >/dev/null 2>&1 command -v "${1}"; then
    printf '[entrypoint] Executing command:\n'
    printf '[entrypoint] "%s"\n' "${@}"
    exec "${@}"
  fi
fi

# see: https://community.fly.io/t/is-it-possible-to-use-my-own-init/12082/3
# see: https://darkghosthunter.medium.com/how-to-understand-s6-overlay-v3-95c81c04f075
# see: https://gist.github.com/darkrain42/02fa589002afa645912d8f8d87bf55f8
# run /init with PID 1, creating a new PID namespace if necessary
if [ "$$" -eq 1 ]; then
    # we already have PID 1
    exec /init "$@"
fi

s6-dumpenv -N /run/s6/container_environment

# create a new PID namespace
exec unshare --pid sh -c '
    # set up /proc and start the real init in the background
    unshare --mount-proc /init "$@" &
    child="$!"
    # forward signals to the real init
    trap "kill -INT \$child" INT
    trap "kill -TERM \$child" TERM
    # wait until the real init exits
    # ("wait" returns early on signals; "kill -0" checks if the process exists)
    until wait "$child" || ! kill -0 "$child" 2>/dev/null; do :; done
' sh "$@"

