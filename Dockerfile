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
RUN apt-get install -y net-tools
RUN apt-get install -y openvpn \
    iproute2 \
    iptables

WORKDIR /root

# Split-tunnel VPN profile (shared certs only; no credentials baked in).
# Credentials come from balena device variables VPN_USER/VPN_PASS at runtime.
COPY profile.ovpn /etc/openvpn/profile.ovpn


# Install dronekit
RUN apt-get install -y python3-pip python3-dev
RUN pip install dronekit --break-system-packages
RUN pip install future --break-system-packages
RUN pip install pyserial --break-system-packages
RUN pip install mavsdk --break-system-packages

# Install agrobot-a1 firmware
WORKDIR /root
RUN git clone https://github.com/MicroLabClub/agrobot-a1.git

# Start SSH daemon directly (no systemd needed)
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
CMD ["/usr/local/bin/start.sh"]