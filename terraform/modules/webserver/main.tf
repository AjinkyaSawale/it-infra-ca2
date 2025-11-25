resource "aws_instance" "web" {
  ami           = "ami-0c7217cdde317cfec"   # Amazon Linux 2 in us-east-1
  instance_type = var.instance_type

  tags = {
    Name = "terraform-webserver"
  }
}
