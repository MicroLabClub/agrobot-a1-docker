FROM balenalib/amd64-ubuntu:latest

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Update and install essentials (ROS2-ready)
RUN apt-get update && apt-get install -y \
    curl wget gnupg lsb-release software-properties-common \
    build-essential git nano htop \
    && rm -rf /var/lib/apt/lists/*


RUN apt-get update && apt-get install -y openssh-server \
    && mkdir /var/run/sshd \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22

RUN add-apt-repository universe
RUN apt-get update
RUN apt-get install alsa-topology-conf
RUN apt-mark hold alsa-topology-conf

WORKDIR /root

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install net-tools

WORKDIR /root

# Start SSH daemon directly (no systemd needed)
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
CMD ["/usr/sbin/sshd", "-D"]