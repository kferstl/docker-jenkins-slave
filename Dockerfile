# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins slave build node.
FROM quay.io/datadog/ubuntu:precise

MAINTAINER Seth Rosenblum <seth@datadoghq.com>

# Set the locale
RUN locale-gen en_US.UTF-8

RUN apt-get update
RUN apt-get install -y apt-transport-https

# Add chow repository
ADD chow.list /etc/apt/sources.list.d/datadog-chow.list

# Make sure the package repository is up to date.
RUN apt-get update

# Install supervisor
RUN apt-get install -y supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install a basic SSH server
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd
ADD sshd.supervisor.conf /etc/supervisor/conf.d/sshd.conf

ADD consul.json /etc/consul.d/default.json
RUN apt-get install -y consul
ADD consul.supervisor.conf /etc/supervisor/conf.d/consul.conf

# Install JDK 7 (latest edition)
RUN apt-get install -y --no-install-recommends openjdk-7-jdk

# Install git
RUN apt-get install -y git

# Add user jenkins to the image
RUN adduser --quiet jenkins
ADD authorized_keys /home/jenkins/.ssh/authorized_keys
ADD ssh_config /home/jenkins/.ssh/config

# Install rvm dependencies
RUN apt-get install -y build-essential curl patch gawk g++ gcc make libc6-dev patch libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev

# Install RVM
USER jenkins
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN /bin/bash -l -c "curl -L get.rvm.io | bash -s stable --ruby"
RUN echo 'source $HOME/.rvm/scripts/rvm' >> $HOME/.bashrc
RUN /bin/bash -l -c "echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
USER root

# Standard SSH port
EXPOSE 22

CMD ["/usr/bin/supervisord"]
