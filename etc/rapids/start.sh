#!/usr/bin/env bash

set -Eeo pipefail

source /home/rapids/.bashrc

# Create or remove ccache compiler symlinks
set-gcc-version $GCC_VERSION >/dev/null 2>&1;

# - ensure conda's installed
# - ensure the rapids conda env is created/updated/activated
source "$COMPOSE_HOME/etc/conda-install.sh" rapids

# activate the rapids conda environment on bash login
echo "source /home/rapids/.bashrc && source activate rapids" > /home/rapids/.bash_login

# If fresh conda env and cmd is build-rapids,
# do `clean-rapids` to delete build artifacts
[ "$FRESH_CONDA_ENV" == "1" ] \
 && [ "$(echo $@)" == "bash -c build-rapids" ] \
 && clean-rapids;

RUN_CMD="$(echo $(eval "echo $@"))"

# Run with gosu because `docker-compose up` doesn't support the --user flag.
# see: https://github.com/docker/compose/issues/1532
if [ "$_UID:$_GID" != "$(id -u):$(id -g)" ]; then
    RUN_CMD="/usr/local/sbin/gosu $_UID:$_GID $RUN_CMD"
fi;

exec -l ${RUN_CMD}
