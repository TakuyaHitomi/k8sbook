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

output "cluster_endpoint" {
  value = aws_eks_cluster.k8sbook_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.k8sbook_cluster.certificate_authority.0.data
}

output "rds_endpoint" {
  value = aws_db_instance.eks_workdb.endpoint
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "distribution_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "batch_user_access_key" {
  value = aws_iam_access_key.k8sbook_batch_user_key.id
}

output "batch_user_secret_access_key" {
  value = aws_iam_access_key.k8sbook_batch_user_key.secret
}
