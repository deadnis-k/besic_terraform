provider "aws" {
  region = "us-east-1"  # Adjust the region as needed
}

resource "aws_security_group" "allow_http" {
  name_prefix = "allow_http_"
  description = "Allow HTTP inbound traffic"
  
  ingress{
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "web_server" {
  ami           = "ami-0df8c184d5f6ae949" # Replace with the correct AMI ID for your region will proprbly be outdated
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_http.name]
  key_name      = "<your_key_name>"  # Replace with your actual SSH key name for access

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl enable httpd
              sudo systemctl start httpd
              EOF

  tags = {
    Name = "WebServer"
  }
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
}

resource "local_file" "public_ip_file" {
  content  = aws_instance.web_server.public_ip
  filename = "${path.module}/public_ip.txt"
}
