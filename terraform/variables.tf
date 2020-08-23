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

variable "rds_subnet1" {
  default = "192.168.3.0/24"
}

variable "rds_subnet2" {
  default = "192.168.4.0/24"
}

variable "op_subnet" {
  default = "192.168.5.0/24"
}

variable "op_image_id" {
  default = "ami-0cc75a8978fbbc969"
}

variable "snapshot_identifier" {
  default = "arn:aws:rds:ap-northeast-1:643143527856:snapshot:eks-workdb-initial"
}
