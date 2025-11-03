#!/bin/bash
set -euo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
HUDDLYUTILS_GIT_REF=${HUDDLYUTILS_GIT_REF:-"9c6228c4d76ee9d9ead5077d8b61872e29763043"} # https://github.com/Huddly/huddlyutils/
[ -f "$script_dir/../run_in_docker.py" ] || \
   { curl -s http://ci0.oslo.huddly.io/huddlyutils-downloader.sh | bash -s -- run_in_docker/run_in_docker.py "$HUDDLYUTILS_GIT_REF"; }
echo "$script_dir/../run_in_docker.py --add-conan-remote conan-center-local -- ${1:-}"
exec "$script_dir/../run_in_docker.py" --add-conan-remote conan-center-local -- ${1:-}
