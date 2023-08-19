resource "aws_security_group" "api_backend" {
  name   = "company elixir api backend"
  vpc_id = module.networking-vpc.vpc_id

  ingress {
    description = "phoenix"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = [
      data.terraform_remote_state.global.outputs.cidr_api
    ]
  }

  ingress {
    description = "epmd"
    from_port   = 4369
    to_port     = 4369
    protocol    = "tcp"
    cidr_blocks = [
      data.terraform_remote_state.global.outputs.cidr_api
    ]
  }

  ingress {
    description = "remote erlang"
    from_port   = 9000
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [
      data.terraform_remote_state.global.outputs.cidr_api
    ]
  }

  tags = {
    Name = "api backend"
  }
}

# need you again later
resource "aws_security_group" "debug_ssh" {
  name        = "debug global ssh"
  description = "debugging only"
  vpc_id      = module.networking-vpc.vpc_id

  ingress {
    description      = "global ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "debug ssh"
  }
}

