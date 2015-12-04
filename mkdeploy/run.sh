#!/bin/bash -e

TOPDIR=$(readlink -f $(dirname "$0")/..)
DEPLOYDIR=${TOPDIR}/mkdeploy
cd "$TOPDIR"

REPODIR=~/aptrepo
IMAGE=mkdeploy
CONTAINER=mkdeploy
CMD=$1; shift || true

build() {
    docker build -t ${IMAGE} ${DEPLOYDIR}/docker
}

run() {
    set -x
    if docker ps -a | grep -q ' deploy *$'; then
	docker start ${CONTAINER}
    else
	docker run \
	    -d \
	    -v ${TOPDIR}:/opt/mkdocker \
	    -v ${REPODIR}:/opt/aptrepo \
	    -p 2222:22 \
	    -p 80:80 \
	    --name=${CONTAINER} \
	    ${IMAGE}
    #	--restart=always \
    fi

}

shell() {
    set -x
    if test -z "$*"; then
	docker exec -it ${CONTAINER} bash -i
    else
	docker exec -it ${CONTAINER} "$@"
    fi
}

stop() {
    set -x
    docker stop ${CONTAINER}
}

restart() {
    set -x
    docker restart ${CONTAINER}
}

destroy() {
    set -x
    stop || true
    docker rm ${CONTAINER}
}

init() {
    set -x
    if test "${MKDOCKER_CONTAINER}" != 1; then
	# Run outside of container
	docker run -it --rm \
	    -v ${TOPDIR}:/opt/mkdocker \
	    -v ${REPODIR}:/opt/aptrepo \
	    ${IMAGE} /opt/mkdocker/mkdeploy/run.sh init
    else
	# Run inside container

	# Create log directory for supervisord, rsyslogd, apache2
	mkdir -p /opt/aptrepo/log

	# Set up SSH keys
	if ! test -d /opt/aptrepo/.ssh; then
	    install -d -o aptrepo -g aptrepo -m 700 /opt/aptrepo/.ssh
	    ssh-keygen -N '' -C 'mkdeploy' -f /opt/aptrepo/.ssh/id_rsa
	    cp /opt/aptrepo/.ssh/id_rsa.pub /opt/aptrepo/.ssh/authorized_keys
	    chown -R aptrepo:aptrepo /opt/aptrepo/.ssh
	fi	
    fi
}

case "$CMD" in
    build) build ;;
    run) run ;;
    shell) shell "$@" ;;
    stop) stop ;;
    restart) restart ;;
    destroy) destroy ;;
    init) init ;;
    *) echo "Usage: $0 [ build | run | shell [cmd [arg ...]] |" \
	"stop | restart | destroy | init ]" >&2; exit 1 ;;
esac
