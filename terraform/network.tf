# k8sbook 用の VPC
resource "aws_vpc" "k8sbook_vpc" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.cluster_base_name}_vpc"
  }
}

resource "aws_subnet" "worker_subnet1" {
  vpc_id                  = aws_vpc.k8sbook_vpc.id
  cidr_block              = var.worker_subnet1
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = "true"

  tags = {
    Name                                    = "${var.cluster_base_name}_subnet1"
    "kubernetes.io/cluster/k8sbook_cluster" = "shared"
  }
}

resource "aws_subnet" "worker_subnet2" {
  vpc_id                  = aws_vpc.k8sbook_vpc.id
  cidr_block              = var.worker_subnet2
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = "true"

  tags = {
    Name                                    = "${var.cluster_base_name}_subnet2"
    "kubernetes.io/cluster/k8sbook_cluster" = "shared"
  }
}

resource "aws_subnet" "worker_subnet3" {
  vpc_id                  = aws_vpc.k8sbook_vpc.id
  cidr_block              = var.worker_subnet3
  availability_zone       = var.availability_zone3
  map_public_ip_on_launch = "true"

  tags = {
    Name                                    = "${var.cluster_base_name}_subnet3"
    "kubernetes.io/cluster/k8sbook_cluster" = "shared"
  }
}

resource "aws_subnet" "rds_subnet1" {
  vpc_id            = aws_vpc.k8sbook_vpc.id
  cidr_block        = var.rds_subnet1
  availability_zone = var.availability_zone1

  tags = {
    Name = "${var.cluster_base_name}_rds_subnet1"
  }
}

resource "aws_subnet" "rds_subnet2" {
  vpc_id            = aws_vpc.k8sbook_vpc.id
  cidr_block        = var.rds_subnet2
  availability_zone = var.availability_zone2

  tags = {
    Name = "${var.cluster_base_name}_rds_subnet2"
  }
}

resource "aws_subnet" "op_subnet" {
  vpc_id                  = aws_vpc.k8sbook_vpc.id
  cidr_block              = var.op_subnet
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.cluster_base_name}_op_subnet"
  }
}

# インターネットに接続用の gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8sbook_vpc.id
}


resource "aws_route_table" "worker_subnet_route_table" {
  vpc_id = aws_vpc.k8sbook_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.cluster_base_name}_woker_subnet_route_table"
  }
}

# worker_subnet1 と worker_subnet_route_table の関連付け
resource "aws_route_table_association" "worker_subnet1_route_table_association" {
  subnet_id      = aws_subnet.worker_subnet1.id
  route_table_id = aws_route_table.worker_subnet_route_table.id
}

# worker_subnet2 と worker_subnet_route_table の関連付け
resource "aws_route_table_association" "worker_subnet2_route_table_association" {
  subnet_id      = aws_subnet.worker_subnet2.id
  route_table_id = aws_route_table.worker_subnet_route_table.id
}

# worker_subnet3 と worker_subnet_route_table の関連付け
resource "aws_route_table_association" "worker_subnet3_route_table_association" {
  subnet_id      = aws_subnet.worker_subnet3.id
  route_table_id = aws_route_table.worker_subnet_route_table.id
}

# op_subnet と worker_subnet_route_table の関連付け
resource "aws_route_table_association" "op_subnet_route_table_association" {
  subnet_id      = aws_subnet.op_subnet.id
  route_table_id = aws_route_table.worker_subnet_route_table.id
}

# RDS instance の security group
resource "aws_security_group" "rds_security_group" {
  name        = "rds_security_group"
  description = "security group for rds instance"
  vpc_id      = aws_vpc.k8sbook_vpc.id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.worker_subnet1,
      var.worker_subnet2,
      var.worker_subnet3,
      var.op_subnet
    ]
  }

  # 全ての外向きの通信を許可する
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "op_security_group" {
  name        = "op_security_group"
  description = "security group for op instance"
  vpc_id      = aws_vpc.k8sbook_vpc.id

  # 全ての外向きの通信を許可する
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# op instnace が SSM にアクセスするための VPC endpoint
resource "aws_vpc_endpoint" "sns_endpoint" {
  vpc_id            = aws_vpc.k8sbook_vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.op_subnet.id
  ]

  security_group_ids = [
    aws_security_group.ssm_endpoint_security_group.id,
  ]

  private_dns_enabled = true
}

# SSM VPC endpoint の security group
# op security group からの通信のみを受け付ける
resource "aws_security_group" "ssm_endpoint_security_group" {
  name        = "ssm_endpoint_security_group"
  description = "security group for ssm endpoint"
  vpc_id      = aws_vpc.k8sbook_vpc.id

  # op instance が所属するセキュリティグループから 443 ポートへの通信を受け付ける
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.op_security_group.id]
  }

  # 全ての外向きの通信を許可する
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
