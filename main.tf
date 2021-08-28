terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  shared_credentials_file = "credentials.txt"
  profile                 = "customprofile"
  region                  = "eu-west-1"
}

resource "aws_key_pair" "adminuser" {
  key_name   = "terraform"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4a25ULvgzdR4lKqN+rdf/WpDcLvqud41PQvR8jyOhgp9pKU8w//+KHQUwkOcVEkQuWPk8FVV4GfhSb6M+h56bvByHQVwuTNo9IIfOlpgsoDSiYkfeEpk5v9PoW2vV9ZZIXdDUyZP7mMFBHl55oRg2+VfyOxyWyED7s6WDnYyV1Lm+9j5ZMFS5cmBwHqOsyO4AP4MUd6zJEgnrXBXfBg1OPD0AkIs3zWk+0qpDkDh0cWl3FzCLSe1TZzWQQ1qClEwMDeUlYOWnN0aJuFb7g/ydwcLbA1xmJh0M0X2t41TUE42zi9mkDKLbayvBf97pXWGNEZz+ag4oSs9DTIGQksGTtSs2bw7EiPU4ZopU1d1eJxGeIrtrvwYtrLpM3GoP9I6KHsH4yVO/QjrtRL1bjzum73i6h0V1mmT0hr/iZVhh5MAHAvE8fnxF81lapNpbexS/kUyUth5qBnjWacdAaPEFuY644t2Bq7X3TvmvpgL4jPQArkfMOGdZiGZbElsG94s= user@x5dij"
}

resource "aws_instance" "app_server01" {
  ami             = "ami-0a8e758f5e873d1c1"
  instance_type   = "t2.medium"
  user_data       = file("digichlist.sh")
  security_groups = ["web-servers", "allow_ssh"]
  key_name        = "terraform"

  tags = {
    Name = "Eschool"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow inbound SSH"
  }
}

resource "aws_security_group" "web-servers" {
  name        = "web-servers"
  description = "Allow HTTP/S inbound traffic"

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http/s_to_web_servers"
  }
}
