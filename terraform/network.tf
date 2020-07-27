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
  vpc_id            = aws_vpc.k8sbook_vpc.id
  cidr_block        = var.worker_subnet1
  availability_zone = var.availability_zone1

  tags = {
    Name = "${var.cluster_base_name}_subnet1"
  }
}

resource "aws_subnet" "worker_subnet2" {
  vpc_id            = aws_vpc.k8sbook_vpc.id
  cidr_block        = var.worker_subnet2
  availability_zone = var.availability_zone2

  tags = {
    Name = "${var.cluster_base_name}_subnet2"
  }
}

resource "aws_subnet" "worker_subnet3" {
  vpc_id            = aws_vpc.k8sbook_vpc.id
  cidr_block        = var.worker_subnet2
  availability_zone = var.availability_zone1

  tags = {
    Name = "${var.cluster_base_name}_subnet3"
  }
}

# インターネットに接続用の gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8sbook_vpc.id
}


# RDS subnet の route table
# デフォルトのまま
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

## RDS instance の security group
#resource "aws_security_group" "rds_security_group" {
#  name        = "rds_security_group"
#  description = "security group for rds instance"
#  vpc_id      = aws_vpc.k8sbook_vpc.id
#
#  # Lambda 関数が所属するセキュリティグループから 3306 ポートへの接続のみ許可する
#  ingress {
#    from_port       = 3306
#    to_port         = 3306
#    protocol        = "tcp"
#    security_groups = ["${aws_security_group.lambda_security_group.id}"]
#  }
#
#  # 全ての外向きの通信を許可する
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
#
## Lambda 関数の security group
#resource "aws_security_group" "lambda_security_group" {
#  name        = "lambda_security_group"
#  description = "security group for lambda functions"
#  vpc_id      = aws_vpc.k8sbook_vpc.id
#
#  # 全ての外向きの通信を許可する
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
#
## Lamda 関数が SNS にアクセスするための VPC endpoint
#resource "aws_vpc_endpoint" "sns_endpoint" {
#  vpc_id            = aws_vpc.k8sbook_vpc.id
#  service_name      = "com.amazonaws.ap-northeast-1.sns"
#  vpc_endpoint_type = "Interface"
#
#  subnet_ids = [
#    "${aws_subnet.lambda_subnet.id}"
#  ]
#
#  security_group_ids = [
#    "${aws_security_group.sns_endpoint_security_group.id}",
#  ]
#
#  private_dns_enabled = true
#}
#
## SNS VPC endpoint の security group
## lambda security group からの通信のみを受け付ける
#resource "aws_security_group" "sns_endpoint_security_group" {
#  name        = "sns_endpoint_security_group"
#  description = "security group for sns endpoint"
#  vpc_id      = aws_vpc.k8sbook_vpc.id
#
#  # Lambda 関数が所属するセキュリティグループから 443 ポートへの通信を受け付ける
#  ingress {
#    from_port       = 443
#    to_port         = 443
#    protocol        = "tcp"
#    security_groups = ["${aws_security_group.lambda_security_group.id}"]
#  }
#
#  # 全ての外向きの通信を許可する
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
#
## Lambda 関数が DynamoDB にアクセスするための VPC endpoint
#resource "aws_vpc_endpoint" "dynamodb_endpoint" {
#  vpc_id            = aws_vpc.k8sbook_vpc.id
#  service_name      = "com.amazonaws.ap-northeast-1.dynamodb"
#  vpc_endpoint_type = "Gateway"
#
#  route_table_ids = [
#    "${aws_route_table.lambda_subnet_route_table.id}"
#  ]
#}
