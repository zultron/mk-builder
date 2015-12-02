FROM debian:jessie
MAINTAINER GP Orcullo <kinsamanka@gmail.com>

# install required dependencies
RUN	apt-get update && \
	apt-get -y upgrade && \
	apt-get -y --no-install-recommends install \
	    debootstrap \
	    proot \
	    locales \
	    rubygems \
	    git

# Set the locale
RUN	locale-gen en_US.UTF-8  
ENV	LANG en_US.UTF-8  
ENV	LANGUAGE en_US:en  
ENV	LC_ALL en_US.UTF-8  

# add packagecloud cli
RUN	gem install package_cloud --no-rdoc --no-ri

# patch debootstrap as /proc cannot be mounted under proot
RUN	sed -i 's/in_target mount -t proc/#in_target mount -t proc/g' \
	    /usr/share/debootstrap/functions

