
#############################################
# COUCHBASE EC2 INSTANCE
#############################################

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "couchbase" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  subnet_id              = var.private_subnets[0]
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = false

  user_data = templatefile("${path.module}/user-data.sh", {
    cluster_name = var.cluster_name
    bucket_name  = var.bucket_name
    username     = var.couchbase_username
    password     = var.couchbase_password
  })

  iam_instance_profile = var.iam_instance_profile_name

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true

    tags = {
      Name = "${var.project_name}-couchbase-root"
    }
  }

  lifecycle {
    ignore_changes = [
      ami,       # Ignorar cambios de AMI (evita recreación innecesaria)
      user_data, # Ignorar cambios en user_data después del primer deploy
    ]
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Name        = "${var.project_name}-couchbase"
  }
}

#############################################
# ELASTIC IP PARA COUCHBASE (OPCIONAL)
# Solo si necesitas acceso admin desde fuera
#############################################

resource "aws_eip" "couchbase" {
  count = var.assign_eip ? 1 : 0

  instance = aws_instance.couchbase.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-couchbase-eip"
  }
}
