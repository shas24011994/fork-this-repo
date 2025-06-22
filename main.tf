provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}
resource "aws_security_group" "ssh" {
  name_prefix = "ssh-allow-"
  description = "Allow SSH inbound traffic"

  ingress {
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
resource "aws_instance" "myinstance" {
  count                       = 1
  ami                         = "ami-084568db4383264d4" # Ubuntu 22.04 LTS x86_64
  instance_type               = "t3.micro"
  availability_zone           = "us-east-1a"
  key_name                    = "aws-secret"
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "web-${count.index}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file("/workspace/aws-secret.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install docker.io -y",
      "git clone https://github.com/rajendra0968jangid/htmlcodelive",
      #   "sudo rm -f /var/www/html/*",
      "cd /home/ubuntu/htmlcodelive",
      "sudo docker build -t htmlsite .",
      "sudo docker run -d --name container1 -p 80:80 htmlsite"
      #   "sudo mv ./htmlcodelive/* /var/www/html/",
      #   "sudo systemctl restart nginx"
    ]
  }
}



