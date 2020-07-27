variable "cluster_base_name" {
  default = "k8sbook"
}

variable "availability_zone1" {
  default = "ap-northeast-1a"
}

variable "availability_zone2" {
  default = "ap-northeast-1c"
}

variable "availability_zone3" {
  default = "ap-northeast-1d"
}

variable "worker_subnet1" {
  default = "192.168.0.0/24"
}

variable "worker_subnet2" {
  default = "192.168.1.0/24"
}

variable "worker_subnet3" {
  default = "192.168.2.0/24"
}

# RDS instance の username
variable "rds_username" {
  default = "root"
}

# RDS instance の password 
variable "rds_password" {
  default = "sudokudb"
}

# RDS instance の database 名
variable "rds_database" {
  default = "sudokudb"
}
