FROM debian:jessie
MAINTAINER GP Orcullo <kinsamanka@gmail.com>

ENV	TERM dumb

# install required dependencies
RUN	apt-get update && \
	apt-get -y upgrade && \
	apt-get -y --no-install-recommends install \
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
RUN	apt-get -y --no-install-recommends install \
		qemu-user-static
ADD	proot-helper /bin/

ENV	ROOTFS=/opt/rootfs

ADD	bin/* ${ROOTFS}/usr/bin/

###########################################################################
# Below here, build the chroot

# These variables configure the build.  Don't move them higher in the
# file to take as much advantage of Docker's caching as possible.
ENV SUITE jessie
ENV ARCH amd64

# FIXME testing
RUN	env

# install native cross-compiler if armhf arch
ADD	http://emdebian.org/tools/debian/emdebian-toolchain-archive.key /tmp/
RUN	test $ARCH != armhf || ( \
	    apt-key add /tmp/emdebian-toolchain-archive.key && \
	    echo "deb http://emdebian.org/tools/debian/ jessie main" >> \
		/etc/apt/sources.list.d/emdebian.list && \
	    dpkg --add-architecture ${ARCH} && \
	    apt-get update && \
	    apt-get install -y --no-install-recommends \
	        crossbuild-essential-${ARCH}; \
	)

# build under /opt
RUN     cd /opt && mkdir -p ${ROOTFS}/opt && \
        debootstrap --foreign --no-check-gpg --include=ca-certificates \
            --arch=${ARCH} ${SUITE} rootfs http://httpredir.debian.org/debian && \
        proot-helper /debootstrap/debootstrap --second-stage --verbose

# configure apt
RUN	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE} main" \
	    > ${ROOTFS}/etc/apt/sources.list' && \
	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE}-updates \
	    main" >> ${ROOTFS}/etc/apt/sources.list' && \
	sh -c 'echo "deb http://security.debian.org ${SUITE}/updates main" \
	    >> ${ROOTFS}/etc/apt/sources.list' && \
	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE}-backports \
 	    main" >> ${ROOTFS}/etc/apt/sources.list' && \
	proot-helper apt-get update 

# install dependencies
ADD	mk_depends ${ROOTFS}/tmp/
RUN	proot-helper install_deps ${SUITE} && \
	rm ${ROOTFS}/tmp/*

# cleanup apt
RUN	proot-helper apt-get clean

# fix resolv.conf
RUN	sh -c 'echo "nameserver 8.8.8.8" > ${ROOTFS}/etc/resolv.conf' && \
	sh -c 'echo "nameserver 8.8.4.4" >>${ROOTFS}/etc/resolv.conf'
