# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins slave build node.
FROM datadog/ubuntu:precise

MAINTAINER Seth Rosenblum <seth@datadoghq.com>

# Make sure the package repository is up to date.
RUN apt-get update

# Install a basic SSH server
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd

# Install JDK 7 (latest edition)
RUN apt-get install -y --no-install-recommends openjdk-7-jdk

# Install git
RUN apt-get install -y git

# Add user jenkins to the image
RUN adduser --quiet jenkins
ADD authorized_keys /home/jenkins/.ssh/authorized_keys
ADD known_hosts /home/jenkins/.ssh/known_hosts
ADD ssh_config /home/jenkins/.ssh/config

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
