FROM machinekit/mk-builder:base
MAINTAINER GP Orcullo <kinsamanka@gmail.com>
#
# These variables configure the build.
#
ENV SUITE [suite]
ENV ARCH  [arch]
#
# [Leave surrounding comments to eliminate merge conflicts]
#

ENV PROOT_OPTS "-b /dev/urandom"

# create chroot
ADD wheezy.conf jessie.conf raspbian.conf /
RUN multistrap -f /${SUITE}.conf -a ${ARCH} -d ${ROOTFS}
RUN proot-helper /var/lib/dpkg/info/dash.preinst install
RUN proot-helper dpkg --configure -a

ENV PROOT_OPTS "-b /dev/pts -b /dev/shm -b /dev/urandom"

# mk_depends lists deps independent of $SUITE and $ARCH
ADD mk_depends ${ROOTFS}/tmp/

# copy arm-linux-gnueabihf-* last to clobber package installs
ADD bin/* ${ROOTFS}/tmp/

# fix resolv.conf
# 3rd-party MK deps repo
# install MK dependencies
# cython package is in backports on Wheezy
# tcl/tk latest is v. 8.5 in Wheezy
# cleanup apt
# use modified arm-linux-gnueabihf-* if running on wheezy
# else use native arm-linux-gnueabihf-* 
# cleanup
# update ccache symlinks

RUN echo "nameserver 8.8.8.8\nnameserver 8.8.4.4" \
        > ${ROOTFS}/etc/resolv.conf
RUN proot-helper apt-key adv --keyserver hkp://keys.gnupg.net \
        --recv-key 43DDF224
RUN echo "deb http://deb.machinekit.io/debian ${SUITE} main" \
         > ${ROOTFS}/etc/apt/sources.list.d/machinekit.list
RUN proot-helper apt-get update
RUN proot-helper xargs -a /tmp/mk_depends apt-get install -y
RUN rm ${ROOTFS}/tmp/mk_depends
RUN (test $SUITE = wheezy \
        && proot-helper apt-get install -y -t wheezy-backports cython \
        || proot-helper apt-get install -y cython)
RUN (test $SUITE = wheezy \
        && proot-helper apt-get install -y tcl8.5-dev tk8.5-dev \
        || proot-helper apt-get install -y tcl8.6-dev tk8.6-dev)
RUN proot-helper apt-get clean
RUN (rm -f /var/lib/apt/lists/* ${ROOTFS}/var/lib/apt/lists/* || true)
RUN (test $ARCH = armhf && test $SUITE = wheezy \
        && cp ${ROOTFS}/tmp/arm-* ${ROOTFS}/usr/bin/ \
        || true)
RUN (test $ARCH = armhf && test $SUITE != wheezy \
        && proot-helper sh -c '\
            for a in $(ls /host-rootfs/usr/bin/arm-linux-gnueabihf-*); \
            do \
                ln -sf $a /usr/bin; \
            done' \
        || true)
RUN rm ${ROOTFS}/tmp/* wheezy.conf jessie.conf raspbian.conf
RUN proot-helper dpkg-reconfigure ccache
