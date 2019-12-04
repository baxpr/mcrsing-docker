FROM ubuntu:18.04
LABEL maintainer="baxter.rogers@vanderbilt.edu"

# System packages
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y \
      autoconf \
      build-essential \
      cpio \
      curl \
      default-jdk \
      gcc \
      gfortran \
      git \
      imagemagick \
      libarchive-dev \
      libtool \
      man \
      sudo \
      unzip \
      vim \
      wget \
      xauth \
      xterm

# Fix imagemagick policy to allow PDF output. See https://usn.ubuntu.com/3785-1/
RUN sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' \
	  /etc/ImageMagick-6/policy.xml

# Download and run the MCR installer, then clean up.
RUN cd /tmp && \
    mkdir MCR_installer && \
    cd MCR_installer && \
    wget -nv "http://ssd.mathworks.com/supportfiles/downloads/R2019b/Release/2/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2019b_Update_2_glnxa64.zip" && \
    unzip MATLAB_Runtime_R2019b_Update_2_glnxa64.zip && \
    ./install -mode silent -agreeToLicense yes && \
    cd - && \
    rm -r MCR_installer

# Singularity
#ARG singver=3.4.2
#RUN apt-get update && apt-get install -y squashfs-tools && \
#    cd /tmp && \
#    wget -nv "https://github.com/singularityware/singularity/releases/download/v${singver}/singularity-${singver}.tar.gz" && \
#    tar -xzvf singularity-${singver}.tar.gz && \
#    cd singularity && \
#    ./configure --prefix=/usr/local && \
#    make && \
#    make install && \
#    cd - && \
#    rm -r singularity-${singver}.tar.gz singularity

# Singularity
# https://sylabs.io/guides/3.0/user-guide/installation.html
# http://neuro.debian.net/
RUN wget -O- http://neuro.debian.net/lists/bionic.us-tn.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list && \
    sudo apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9 && \
    apt-get update && apt-get install -y singularity-container && singularity --version
