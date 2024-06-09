#!/bin/bash

# Update and upgrade apt packages
sudo apt-get update && sudo apt-get upgrade -y

# Allow traffic on port 25565
sudo ufw allow 25565

# Install OpenJDK (Java)
sudo apt-get install -y openjdk-21-jdk

# Download the Minecraft server JAR
wget https://web.archive.org/web/20240510183150/https://piston-data.mojang.com/v1/objects/145ff0858209bcfc164859ba735d4199aafa1eea/server.jar

# Accept the EULA
echo "eula=true" > eula.txt

# Create a systemd service file for Minecraft server
sudo bash -c 'cat << EOF > /etc/systemd/system/minecraft.service
[Unit]
Description=Minecraft Server
After=network.target

[Service]
WorkingDirectory=/home/ubuntu
ExecStart=/usr/bin/java -Xmx1024M -Xms1024M -jar server.jar nogui
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd and enable the Minecraft server service
sudo systemctl daemon-reload
sudo systemctl enable minecraft
sudo systemctl start minecraft
