FROM ubuntu:20.04

# Enable deb-src
RUN for l in `awk '/^deb /{getline; print NR}' /etc/apt/sources.list`; do sed -i "${l}s/^# *//" /etc/apt/sources.list; done

# Update packages and setup timezone
RUN apt-get update && apt-get -y upgrade && \
      apt-get -y install tzdata

ENV TZ=Europe/Zurich
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
      echo $TZ > /etc/timezone
RUN dpkg-reconfigure --frontend=noninteractive tzdata

RUN useradd -m -g users -s /bin/bash user
RUN mkdir -p /etc/sudoers.d
RUN echo 'user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/user

# Tools required for kernel compilation
RUN apt-get -y install build-essential libncurses-dev gawk flex bison openssl \
    libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev \
    autoconf git

# Build dependencies for kernel compilation
RUN apt-get -y build-dep linux linux-signed

# Generic tools
RUN apt-get -y install file unzip zip xz-utils git cmake \
    python3 git tmux htop python3 python parallel vim tree psmisc

RUN mkdir /opt/kernel
ADD ukharon_custom_kernel.tar /opt/kernel
RUN chown -R user:users /opt/kernel

ADD entry.sh /entry.sh

ENTRYPOINT ["/entry.sh"]
