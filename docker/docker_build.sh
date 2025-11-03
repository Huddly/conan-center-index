#!/bin/bash
# This file is called by run_in_docker.sh to setup the docker image
set -eEuo pipefail
set -x

docker_directory="${1}"
write_hash_to_this_file="${2}"

script_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
repo_root=$(readlink -f $script_dir/..)

export SOURCE_DATE_EPOCH=0

function repro_tar {
    # https://reproducible-builds.org/docs/archives/
    tar --sort=name \
      --format=pax \
      --mtime="@${SOURCE_DATE_EPOCH}" \
      --owner=0 --group=0 --numeric-owner \
      --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
      $@
}

LOCAL_UID=$(id -u)
build_arg="--build-arg DOCKER_USER_UID=$LOCAL_UID"
if [ ! -z ${ARTIFACTORY_USER+x} ]; then
    docker login --username $ARTIFACTORY_USER --password-stdin http://artifactory.huddly.io << EOF
$ARTIFACTORY_ACCESS_TOKEN
EOF
    build_arg="$build_arg --build-arg ARTIFACTORY_USER=$ARTIFACTORY_USER --build-arg ARTIFACTORY_ACCESS_TOKEN=$ARTIFACTORY_ACCESS_TOKEN"
    if [ ! -s $docker_directory/conan-config.tar ]; then # if it does not exist OR has size 0
        rm -rf $docker_directory/conan-config
        git clone --depth=1 --branch=master git@github.com:Huddly/conan-config.git $docker_directory/conan-config
        rm -rf $docker_directory/conan-config/.git
        repro_tar -C $docker_directory -cf $docker_directory/conan-config.tar conan-config
    fi
    cat > $docker_directory/pip.conf << EOF
[global]
trusted-host = artifactory-local.oslo.huddly.io:8082
index-url = http://$ARTIFACTORY_USER:$ARTIFACTORY_ACCESS_TOKEN@artifactory-local.oslo.huddly.io:8082/artifactory/api/pypi/python-virtual/simple
EOF
else
    touch $docker_directory/conan-config.tar
    if ! cp -a ~/.pip/pip.conf $docker_directory/; then
        touch $docker_directory/pip.conf
        echo "WARNING: No ~/.pip/pip.conf found. Authenticatio against artifactory will likely fail"
    fi
fi

repro_tar -C $repo_root -cf $docker_directory/python-projects.tar docker/conanenv
sha256sum $docker_directory/*.tar

######## Tag for Docker image
if [ ! -z ${CHANGE_BRANCH+x} ]; then
    branch_name="${CHANGE_BRANCH}"
elif [ ! -z ${BRANCH_NAME+x} ]; then
    branch_name="${BRANCH_NAME}"
else
    branch_name="locally"
fi
# normalize and filter away characters docker doesn't accept
branch_name=$(echo $branch_name | tr "[:upper:]" "[:lower:]" | tr '+#$%^*(){}|"' '_')

########
mkdir -p artifacts
build_arg="$build_arg --tag falcon-dependencies/$branch_name --add-host=artifactory.huddly.io:$(getent hosts artifactory.huddly.io | awk '{ print $1 }')"

if [ -n "${JENKINS_HOME:-}" ]; then
    build_arg="--quiet $build_arg"
fi

rm $write_hash_to_this_file
docker build $build_arg $docker_directory --iidfile $write_hash_to_this_file | tee artifacts/docker_build.log
cat $write_hash_to_this_file

