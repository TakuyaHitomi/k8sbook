locals {
  secret_json  = jsondecode(data.aws_secretsmanager_secret_version.k8sbook_secret_version.secret_string)
  rds_username = local.secret_json["rds_username"]
  rds_password = local.secret_json["rds_password"]
}

# RDS instance が入る subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = ["${aws_subnet.rds_subnet1.id}", "${aws_subnet.rds_subnet2.id}"]

  tags = {
    Name = "RDS subnet group"
  }
}

# RDS parameter group を作成
resource "aws_db_parameter_group" "eks_workdb_parameter_group" {
  family      = "postgres10"
  description = "parameter group for postgreSQL 10.6"
}

# RDS instance
resource "aws_db_instance" "eks_workdb" {
  allocated_storage    = 30
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "10.6"
  instance_class       = "db.t2.micro"
  name                 = "eks_workdb"
  username             = local.rds_username
  password             = local.rds_password
  parameter_group_name = aws_db_parameter_group.eks_workdb_parameter_group.id
  identifier           = "eks-workdb"
  multi_az             = "false"
  publicly_accessible  = "false"

  # 削除保護を無効
  deletion_protection = "false"

  # 暗号化を有効。暗号化のキーはデフォルト
  # db.t2.micro ではサポートされない
  # storage_encrypted = "true"

  # Lambda 関数の所属するセキュリティグループからのみ接続を受け付ける
  vpc_security_group_ids = ["${aws_security_group.rds_security_group.id}"]

  # RDS instance 用の subnet group を指定
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  # RDS instance を削除する際に snapshot を取得しない
  skip_final_snapshot =  "true"

  # RDS instance を削除する際に取得する snapshot の名前
  # final_snapshot_identifier = "sudokudb-final-snapshot"

  # maintenance window を UTC で指定
  maintenance_window = "Sun:17:00-Sun:20:00"
  backup_window      = "20:03-22:03"

  # backup は 7 日間保持
  backup_retention_period = 7

  # 変更を即座に反映
  apply_immediately = "true"

  # snapshot から立ち上げる場合は以下の変数を指定
  snapshot_identifier = var.snapshot_identifier
}

## RDS parameter group を作成して文字コードを utf8mb4 に設定
#resource "aws_db_parameter_group" "utf8mb4" {
#  name        = "utf8mb4"
#  family      = "mysql5.7"
#  description = "enable 'real' utf8 (utf8mb4)"
#
#  parameter {
#    name  = "character_set_client"
#    value = "utf8mb4"
#  }
#
#  parameter {
#    name  = "character_set_database"
#    value = "utf8mb4"
#  }
#
#  parameter {
#    name  = "character_set_connection"
#    value = "utf8mb4"
#  }
#
#  parameter {
#    name  = "character_set_server"
#    value = "utf8mb4"
#  }
#
#  parameter {
#    name  = "character_set_results"
#    value = "utf8mb4"
#  }
#
#  parameter {
#    name  = "collation_server"
#    value = "utf8mb4_unicode_ci"
#  }
#
#  parameter {
#    name  = "collation_connection"
#    value = "utf8mb4_unicode_ci"
#  }
#}
#
## RDS instance
#resource "aws_db_instance" "rds_instance" {
#  allocated_storage     = 100
#  max_allocated_storage = 200
#  storage_type          = "gp2"
#  engine                = "mysql"
#  engine_version        = "5.7"
#  instance_class        = "db.t3.medium"
#  name                  = var.rds_database
#  username              = var.rds_username
#  password              = var.rds_password
#  parameter_group_name  = aws_db_parameter_group.utf8mb4.id
#  identifier            = var.rds_database
#
#  # 削除保護を有効
#  deletion_protection = "true"
#
#  # 暗号化を有効。暗号化のキーはデフォルト
#  storage_encrypted = "true"
#
#  # Lambda 関数の所属するセキュリティグループからのみ接続を受け付ける
#  vpc_security_group_ids = ["${aws_security_group.rds_security_group.id}"]
#
#  # RDS instance 用の subnet group を指定
#  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
#
#  # RDS instance を削除する際に取得する snapshot の名前
#  final_snapshot_identifier = "sudokudb-final-snapshot"
#
#  # maintenance window を UTC で指定
#  maintenance_window = "Sun:17:00-Sun:20:00"
#  backup_window      = "20:03-22:03"
#
#  # backup は 7 日間保持
#  backup_retention_period = 7
#
#  # 変更を即座に反映
#  apply_immediately = "true"
#
#  # snapshot から立ち上げる場合は以下の変数を指定
#  # snapshot_identifier = var.snapshot_identifier
#}
