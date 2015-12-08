FROM kinsamanka/mkdocker:latest
MAINTAINER GP Orcullo <kinsamanka@gmail.com>

ENV SUITE jessie
ENV ARCH i386

# build under /opt
RUN     cd /opt && \
        debootstrap --foreign --no-check-gpg --include=ca-certificates \
            --arch=${ARCH} ${SUITE} rootfs http://httpredir.debian.org/debian && \
        proot -r /opt/rootfs /debootstrap/debootstrap --second-stage --verbose

# configure apt
RUN	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE} main" \
	    > /opt/rootfs/etc/apt/sources.list' && \
	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE}-updates \
	    main" >> /opt/rootfs/etc/apt/sources.list' && \
	sh -c 'echo "deb http://security.debian.org ${SUITE}/updates main" \
	    >> /opt/rootfs/etc/apt/sources.list' && \
	sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE}-backports \
 	    main" >> /opt/rootfs/etc/apt/sources.list' && \
	proot -r /opt/rootfs apt-get update 

# install dependencies
ADD	https://raw.githubusercontent.com/zultron/mkdocker/master/${SUITE}_mk_depends \
	https://raw.githubusercontent.com/zultron/mkdocker/master/install_${SUITE}_deps.sh \
	/opt/rootfs/tmp/
	
RUN	chmod a+x /opt/rootfs/tmp/install_${SUITE}_deps.sh && \
	proot -r /opt/rootfs /tmp/install_${SUITE}_deps.sh && \
	rm /opt/rootfs/tmp/*

# cleanup apt
RUN	proot -r /opt/rootfs apt-get clean

# fix resolv.conf
RUN	sh -c 'echo "nameserver 8.8.8.8" > /opt/rootfs/etc/resolv.conf' && \
	sh -c 'echo "nameserver 8.8.4.4" >>/opt/rootfs/etc/resolv.conf'
