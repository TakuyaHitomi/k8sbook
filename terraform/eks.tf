resource "aws_eks_cluster" "k8sbook_cluster" {
  name     = "k8sbook_cluster"
  role_arn = aws_iam_role.k8sbook_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.worker_subnet1.id, aws_subnet.worker_subnet2.id, aws_subnet.worker_subnet3.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.k8sbook_cluster_policy,
    aws_iam_role_policy_attachment.k8sbook_service_policy,
  ]
}

resource "aws_eks_node_group" "k8sbook_nodegroup" {
  cluster_name    = aws_eks_cluster.k8sbook_cluster.name
  node_group_name = "k8sbook_nodegroup"
  node_role_arn   = aws_iam_role.k8sbook_nodegroup_role.arn
  instance_types  = ["t2.small"]
  subnet_ids      = [aws_subnet.worker_subnet1.id, aws_subnet.worker_subnet2.id, aws_subnet.worker_subnet3.id]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.k8sbook_nodegroup_policy,
    aws_iam_role_policy_attachment.k8sbook_nodegroup_cni_policy,
    aws_iam_role_policy_attachment.k8sbook_nodegroup_ecr_readonly,
  ]
}
