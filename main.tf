provider "aws" {
  region = "us-east-2"
  profile = "ay-test-terra"
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "in-gw"
  }
}  

resource "aws_route_table" "rout-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  
  

  tags = {
    Name = "Routone"
  }
}

resource "aws_subnet" "subnet" {  
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name= "terra-subnet"
  }
}


  resource "aws_route_table_association" "web-nic" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rout-table.id
}

resource "aws_security_group" "allow-http" {
  name        = "allow-http"
  description = "terraform example for ec2"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "TLS from VPC"
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

resource "aws_network_interface" "assnetw" {
  subnet_id       = aws_subnet.subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow-http.id]

}


resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.assnetw.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}  

resource "aws_instance" "terraform_ec2-instance3" {
  ami = "ami-00dfe2c7ce89a450b"
  instance_type = "t2.micro"
  key_name = "ay_key"
  availability_zone = "us-east-2a"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.assnetw.id
  }

  
  tags = {
    Name = "Terraform ec2 instance2"
  }

}

