output "vpc" {
  value = aws_vpc.k8sbook_vpc.id
}

output "woker_subnets" {
  value = [
    aws_subnet.worker_subnet1.id,
    aws_subnet.worker_subnet2.id,
    aws_subnet.worker_subnet3.id
  ]
}

output "route_table" {
  value = aws_route_table.worker_subnet_route_table.id
}
