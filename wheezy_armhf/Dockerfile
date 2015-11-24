FROM kinsamanka/mkdocker:latest
MAINTAINER GP Orcullo <kinsamanka@gmail.com>

ENV SUITE wheezy
ENV ARCH armhf

# install required dependencies
RUN	apt-get update && \
	apt-get -y --no-install-recommends install \
		qemu-user-static

# install native cross-compiler
ADD	http://emdebian.org/tools/debian/emdebian-toolchain-archive.key /tmp/
RUN	apt-key add /tmp/emdebian-toolchain-archive.key && \
	echo "deb http://emdebian.org/tools/debian/ jessie main" >> \
		/etc/apt/sources.list.d/emdebian.list && \
	dpkg --add-architecture ${ARCH} && \
	apt-get update && \
	apt-get install -y --no-install-recommends crossbuild-essential-${ARCH}

# build under /opt
RUN     cd /opt && \
        debootstrap --foreign --no-check-gpg --include=ca-certificates \
            --arch=${ARCH} ${SUITE} rootfs http://httpredir.debian.org/debian && \
        proot -r /opt/rootfs -q qemu-arm-static \
            /debootstrap/debootstrap --second-stage --verbose

# configure apt
RUN	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE} main" \
	    > /opt/rootfs/etc/apt/sources.list' && \
	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE}-updates \
	    main" >> /opt/rootfs/etc/apt/sources.list' && \
	sh -c 'echo "deb http://security.debian.org ${SUITE}/updates main" \
	    >> /opt/rootfs/etc/apt/sources.list' && \
	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE}-backports \
 	    main" >> /opt/rootfs/etc/apt/sources.list' && \
	proot -r /opt/rootfs -q qemu-arm-static apt-get update 

# install dependencies
ADD	https://raw.githubusercontent.com/kinsamanka/MkDocker/master/${SUITE}_mk_depends \
	https://raw.githubusercontent.com/kinsamanka/MkDocker/master/install_${SUITE}_deps.sh \
	/opt/rootfs/tmp/
	
RUN	chmod a+x /opt/rootfs/tmp/install_${SUITE}_deps.sh && \
	proot -r /opt/rootfs -q qemu-arm-static /tmp/install_${SUITE}_deps.sh && \
	rm /opt/rootfs/tmp/*

ADD	arm-linux-gnueabihf-* /opt/rootfs/usr/bin/

# cleanup apt
RUN	proot -r /opt/rootfs -q qemu-arm-static apt-get clean

# fix resolv.conf
RUN	sh -c 'echo "nameserver 8.8.8.8" > /opt/rootfs/etc/resolv.conf' && \
	sh -c 'echo "nameserver 8.8.4.4" >>/opt/rootfs/etc/resolv.conf'
