#!/bin/sh -ex

# add dovetail gpg key
apt-key adv --keyserver hkp://keys.gnupg.net --recv-key 73571BB9

# update apt sources
echo "deb http://deb.dovetail-automata.com wheezy main" \
	> /etc/apt/sources.list.d/machinekit.list
apt-get update

# install requisite packages
apt-get install -y --no-install-recommends \
	git \
	devscripts \
	fakeroot \
	equivs \
	lsb-release \
	less

# install machinekit build depends
apt-get install -y -t wheezy-backports cython

deps=`cat wheezy_mk_depends`
deps="${deps%
}"

apt-get install -y --no-install-recommends ${deps}
