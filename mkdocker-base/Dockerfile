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

