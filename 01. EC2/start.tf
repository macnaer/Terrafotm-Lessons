// Provider
provider "aws" {
  region     = "eu-north-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


// Create ec2 instance
resource "aws_instance" "EC2-Instance" {
  availability_zone      = "eu-north-1a"
  ami                    = "ami-092cce4a19b438926"
  instance_type          = "t3.micro"
  key_name               = "Stockholm"
  vpc_security_group_ids = [aws_security_group.DefaultTerraformSG.id]

  // Create main disk
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 10
    tags = {
      "name" = "root disk"
    }
  }

  // User script
  user_data = <<EOF
      #!/bin/bash
      echo "Install Apache2"
      sudo apt -y update
      sudo apt -y install apache2
      sudo systemctl start apache2
      sudo systemctl enable apache2
  EOF

  // Tags
  tags = {
    Name = "EC2-Instance"
  }
}


// Create extebded disk
resource "aws_ebs_volume" "Main_disk" {
  size              = 5
  availability_zone = "eu-north-1a"
  type              = "gp2"
  tags = {
    Name = "root disk"
  }
}

// Attacj extended disk to ec2 instance
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.Main_disk.id
  instance_id = aws_instance.EC2-Instance.id
}

// Create security group
resource "aws_security_group" "DefaultTerraformSG" {
  name        = "DefaultTerraformSG"
  description = "Allow 22, 80, 443 inbound taffic"

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
