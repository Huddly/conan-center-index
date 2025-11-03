#!/bin/bash
# Install packages needed for guppy development
# NOTE: this file is also used by docker environment, any changes here will cause a larger docker rebuild
# local and in CI.

set -euxo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

sudo apt-get install -y --no-install-recommends \
    iputils-ping \
    openjdk-8-jdk
