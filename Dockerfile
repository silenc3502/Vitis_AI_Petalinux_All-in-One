FROM		ubuntu:18.04
MAINTAINER	gcccompil3r@gmail.com
LABEL 		authors="gcccompil3r@gmail.com"

#build with docker build --build-arg PETALINUX_INSTALLER=petalinux-v2019.2-final-installer.run -t petalinux

#RUN apt-get update -o Acquire::CompressionTypes::Order::=gz

ARG PETALINUX_INSTALLER
ARG PETALINUX

#ENV DEBIAN_FRONTEND=noninteractive

# add sourcelist
RUN sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/g' /etc/apt/sources.list && \
    cat /etc/apt/sources.list && \
    dpkg --add-architecture i386
   
# Issue - https://forums.xilinx.com/t5/Embedded-Linux/petaconfig-c-kernel-error/td-p/764606
# Issue - https://forums.xilinx.com/t5/Embedded-Linux/Petalinux-2017-4-docker-container/td-p/825802
# Issue - If you wanna need some edit then you need editing tools like vim
# package update
RUN apt-get -y update

# Solve Time Zone Problem
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# For Vitis AI
RUN apt-get install -y \
  libsm6 \
  libxi6 \
  libxrender1 \
  libxrandr2 \
  libfreetype6 \
  libfontconfig \
  git

# Install Apt-Utils
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends apt-utils

# build-essential sudo expect emacs openssh-server
RUN apt-get -y install build-essential sudo expect emacs openssh-server

# gcc gawk diffstat xvfb chrpath socat xterm autoconf
RUN apt-get -y install gcc gawk diffstat xvfb chrpath socat xterm autoconf

# libtool libtool-bin python git net-tools zlib1g-dev
RUN apt-get -y install libtool libtool-bin python git net-tools zlib1g-dev

# libncurses5-dev libssl-dev xz-utils locales
RUN apt-get -y install libncurses5-dev libssl-dev xz-utils locales

# wget tftpd cpio gcc-multilib tofrodos iproute2 gnupg flex bison unzip make
RUN apt-get -y install wget tftpd cpio gcc-multilib tofrodos iproute2 gnupg flex bison unzip make

RUN apt-get -y install texinfo libsdl1.2-dev libglib2.0-dev zlib1g:i386 screen lsb-release vim

# There are libgtk Issue
RUN apt-get -y install libgtk2.0-dev

# Needs libselinux1
RUN apt-get -y install libselinux1

# Needs tar
RUN apt-get -y install tar

# Python-Pip
RUN apt-get -y install python-pip

# locale update
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# adduser vivado
#RUN adduser --disabled-password --gecos '' vivado && \
#    usermod -aG sudo vivado && \
#    echo "vivado ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ARG b_uid
ARG b_gid

ENV TERM xterm

# Sharing the x server with docker. See:
# http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/
RUN export uid=${b_uid} gid=${b_gid} && \
    mkdir -p /home/vivado && \
    echo "vivado:x:${uid}:${gid}:Developer,,,:/home/vivado:/bin/bash" >> /etc/passwd && \
    echo "vivado:x:${uid}:" >> /etc/group && \
    echo "vivado ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vivado && \
    chmod 0440 /etc/sudoers.d/vivado && \
    chown ${uid}:${gid} /home/vivado && \
    chown -R ${uid}:${gid} /opt

# create vivado account
USER vivado
ENV HOME /home/vivado
ENV LANG en_US.UTF-8
WORKDIR /home/vivado

# create directory /opt/xilinx
RUN mkdir -p /opt/xilinx && \
	chown vivado /opt/xilinx

# Copy Installation Config File
COPY --chown=vivado:vivado install_config.txt /home/vivado/install_config.txt

# Vitis Download and Install
ARG VITIS_TAR_HOST
ARG VITIS_TAR_FILE
ARG VITIS_VERSION
RUN echo "Donwloading ${VITIS_TAR_FILE} from ${VITIS_TAR_HOST}" && \
	wget ${VITIS_TAR_HOST}/${VITIS_TAR_FILE}.tar.gz -q && \
	echo "Extracting Vitis tar file" && \
	tar zxf ${VITIS_TAR_FILE}.tar.gz && \
	/home/vivado/${VITIS_TAR_FILE}/xsetup --agree 3rdPartyEULA,WebTalkTerms,XilinxEULA --batch Install --config /home/vivado/install_config.txt && \
	rm -rf ${VITIS_TAR_FILE}*

# Download Board Files
RUN echo "Downloading Board Files"
RUN wget ${VITIS_TAR_HOST}/bdf-master.zip -q
RUN echo "Extracting Board Files"
RUN unzip "bdf-master.zip" -d /opt/xilinx/Vivado/2019.2/data/boards/board_files/
RUN unzip "bdf-master.zip" -d /opt/xilinx/Vitis/2019.2/data/boards/board_files/
RUN rm -rf bdf-master.zip

# create directory /opt/pkg
RUN mkdir -p /opt/pkg && \
    chown vivado /opt/pkg

# Fix Broken Packages
RUN sudo apt-get --fix-broken install

# Update Packages
RUN sudo apt-get update

# Fix Broken Packages
RUN sudo apt-get --fix-broken install

# Install ocl-icd-opencl-dev
RUN sudo apt-get -y install ocl-icd-opencl-dev

# Fix Broken Packages
RUN sudo apt-get --fix-broken install

# Install libboost-dev
RUN sudo apt-get -y install libboost-dev

# Install dialog
RUN sudo apt-get -y install dialog

# Install rsync
RUN sudo apt-get -y install rsync

# Install libboost-filesystem-dev
RUN sudo apt-get -y install libboost-filesystem-dev

# Install uuid-dev
RUN sudo apt-get -y install uuid-dev

# Install dkms
RUN sudo apt-get -y install dkms

# Fix Broken Packages
RUN sudo apt-get --fix-broken install

# Clean
RUN sudo apt-get clean

# Update One more
RUN sudo apt-get update

# Install libprotoc-dev
RUN sudo apt-get -y install libprotoc-dev

# Install protobuf-compiler
RUN sudo apt-get -y install protobuf-compiler

# Install libxml2-dev
RUN sudo apt-get -y install libxml2-dev

# Install libyaml-dev
RUN sudo apt-get -y install libyaml-dev

## Remove Exist XRT
#RUN apt-get remove -y xrt
#
## Remove Python-OpenCL
#RUN apt-get remove -y python-pyopencl

# Download XRT deb file
RUN echo "Downloading XRT from ${VITIS_TAR_HOST}" && \
	wget ${VITIS_TAR_HOST}/xrt_201920.2.3.1301_18.04-xrt.deb -q && \
	echo "Installing XRT deb file" && \
	sudo dpkg -i xrt_201920.2.3.1301_18.04-xrt.deb && \
	rm -rf xrt_201920.2.3.1301_18.04-xrt.deb

# Copy License
RUN mkdir -p /home/vivado/.Xilinx
COPY Xilinx.lic /home/vivado/.Xilinx/

# Add Vitis Tools to PATH
RUN echo "source /opt/xilinx/Vitis/${VITIS_VERSION}/settings64.sh" >> /home/vivado/.bashrc

# Add XRT to PATH
RUN echo "source /opt/xilinx/xrt/setup.sh" >> /home/vivado/.bashrc

# install petalinux
COPY --chown=vivado:vivado accept-eula.sh /home/vivado/accept-eula.sh
COPY --chown=vivado:vivado ${PETALINUX_INSTALLER} /home/vivado/${PETALINUX_INSTALLER}
RUN chmod +x /home/vivado/accept-eula.sh
RUN chmod +x /home/vivado/${PETALINUX_INSTALLER}
RUN /home/vivado/accept-eula.sh /home/vivado/${PETALINUX_INSTALLER} /opt/pkg/petalinux
RUN echo "source /opt/pkg/petalinux/settings.sh" >> /home/vivado/.bashrc
RUN rm -rf accept-eula.sh ${PETALINUX_INSTALLER}

# copy Zybo-Z7-10 BSP
#ADD https://github.com/Digilent/Petalinux-Zybo-Z7-10/releases/download/v2017.4-1/Petalinux-Zybo-Z7-10-2017.4-1.bsp /home/vivado
