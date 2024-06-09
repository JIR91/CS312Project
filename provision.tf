# Configure the AWS provider
provider "aws" {
  region = "us-west-2"
}


# Define the security group for the Minecraft server
resource "aws_security_group" "minecraft_sg" {
  name_prefix = "minecraft-sg-"
  description = "Security group for Minecraft server"

  # Inbound rule to allow SSH access on port 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule to allow Minecraft traffic on port 25565
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Provision the EC2 instance for the Minecraft server
resource "aws_instance" "minecraft_server" {
  ami           = "ami-0cf2b4e024cdb6960" # Ubuntu AMI ID
  instance_type = "t2.medium" # Instance Type

  # Associate the security group
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]

  # Name Instance
  tags = {
    Name = "MinecraftServer"
  }

  # The name of the key pair to use for SSH access
  key_name = "aws"
}


# Generate an Ansible inventory file
resource "local_file" "inventory" {
  content = <<EOT
  [minecraft]
  ${aws_instance.minecraft_server.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/moyo/aws.pem
  EOT
  filename = "${path.module}/inventory"
}


# Output public IP address of the EC2 instance
output "Minecraft_Server_Public_IPv4" {
  value = aws_instance.minecraft_server.public_ip
}