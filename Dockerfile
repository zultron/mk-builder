FROM debian:jessie
MAINTAINER GP Orcullo <kinsamanka@gmail.com>

ENV	TERM dumb
ENV	ROOTFS=/opt/rootfs

# apt config:  silence warnings and set defaults
ENV	DEBIAN_FRONTEND noninteractive
	# container OS
RUN	echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > \
            /etc/apt/apt.conf.d/01norecommend
	# proot OS
RUN	mkdir -p ${ROOTFS}/etc/apt/apt.conf.d && \
	echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > \
            ${ROOTFS}/etc/apt/apt.conf.d/01norecommend

# install required dependencies
RUN	apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install \
	    debootstrap \
	    proot \
	    locales \
	    rubygems \
	    git \
	    bzip2

# add packagecloud cli
RUN	gem install package_cloud --no-rdoc --no-ri

# patch debootstrap as /proc cannot be mounted under proot
RUN	sed -i 's/in_target mount -t proc/#in_target mount -t proc/g' \
	    /usr/share/debootstrap/functions

# for qemu in proot
RUN	apt-get -y install \
		qemu-user-static
ADD	proot-helper /bin/


ADD	bin/* ${ROOTFS}/usr/bin/

###########################################################################
# Below here, build the chroot

# These variables configure the build.  Don't move them higher in the
# file to take as much advantage of Docker's caching as possible.
ENV SUITE jessie
ENV ARCH amd64

# install native cross-compiler if armhf arch
ADD	http://emdebian.org/tools/debian/emdebian-toolchain-archive.key /tmp/
RUN	test $ARCH != armhf || ( \
	    apt-key add /tmp/emdebian-toolchain-archive.key && \
	    echo "deb http://emdebian.org/tools/debian/ jessie main" >> \
		/etc/apt/sources.list.d/emdebian.list && \
	    dpkg --add-architecture ${ARCH} && \
	    apt-get update && \
	    apt-get install -y crossbuild-essential-${ARCH}; \
	)

# build under /opt/rootfs
RUN     mkdir -p /opt/rootfs && \
        debootstrap --foreign --no-check-gpg --include=ca-certificates \
            --arch=${ARCH} ${SUITE} /opt/rootfs http://httpredir.debian.org/debian
RUN	proot-helper /debootstrap/debootstrap --second-stage --verbose

# configure apt
	# official Debian repos
RUN	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE} main" \
	    > ${ROOTFS}/etc/apt/sources.list' && \
	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE}-updates \
	    main" >> ${ROOTFS}/etc/apt/sources.list' && \
	sh -c 'echo "deb http://security.debian.org ${SUITE}/updates main" \
	    >> ${ROOTFS}/etc/apt/sources.list' && \
	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE}-backports \
 	    main" >> ${ROOTFS}/etc/apt/sources.list'
	# 3rd-party MK deps repo
RUN	proot-helper apt-key adv --keyserver hkp://keys.gnupg.net \
	    --recv-key 73571BB9 && \
	echo "deb http://builder2.zultron.com ${SUITE} main" \
	     > ${ROOTFS}/etc/apt/sources.list.d/machinekit.list
	# update apt db
RUN	proot-helper apt-get update 

# install debian development dependencies
RUN	proot-helper apt-get update && \
	proot-helper apt-get install -y \
	    git \
	    devscripts \
	    fakeroot \
	    equivs \
	    lsb-release \
	    less \
	    python-debian

# install MK dependencies
ADD	mk_depends ${ROOTFS}/tmp/
	# mk_depends lists deps independent of $SUITE and $ARCH
RUN	proot-helper xargs -a /tmp/mk_depends apt-get install -y
RUN	rm ${ROOTFS}/tmp/mk_depends
	# cython package is in backports on Wheezy
RUN	test $SUITE = wheezy \
	    && proot-helper apt-get install -y -t wheezy-backports cython \
	    || proot-helper apt-get install -y cython
	# tcl/tk latest is v. 8.5 in Wheezy
RUN	test $SUITE = wheezy \
	    && proot-helper apt-get install -y tcl8.5-dev tk8.5-dev \
	    || proot-helper apt-get install -y tcl8.6-dev tk8.6-dev

# cleanup apt
RUN	proot-helper apt-get clean

# fix resolv.conf
RUN	echo "nameserver 8.8.8.8\nnameserver 8.8.4.4" \
	    > ${ROOTFS}/etc/resolv.conf
