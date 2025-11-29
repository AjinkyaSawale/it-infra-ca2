resource "aws_instance" "web" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = var.instance_type

  # NEW: pin to Subnet A for this test
  subnet_id = "subnet-05ee3aaa56bbfed14"

  tags = {
    Name = "terraform-webserver"
  }
}

