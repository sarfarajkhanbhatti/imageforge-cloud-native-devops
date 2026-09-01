data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "imageforge" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.imageforge.id]
  associate_public_ip_address = true

  key_name = var.key_name

  iam_instance_profile = aws_iam_instance_profile.imageforge.name

  user_data = templatefile(
    "${path.module}/user_data.sh.tpl",
    {
      aws_region = var.aws_region
    }
  )

  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-server"
    }
  )
}