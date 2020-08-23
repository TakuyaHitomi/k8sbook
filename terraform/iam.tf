resource "aws_iam_role" "k8sbook_cluster_role" {
  name = "k8sbook_cluster_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "k8sbook_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8sbook_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "k8sbook_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.k8sbook_cluster_role.name
}

resource "aws_iam_role" "k8sbook_nodegroup_role" {
  name = "k8sbook_nodegroup_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "k8sbook_nodegroup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8sbook_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "k8sbook_nodegroup_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8sbook_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "k8sbook_nodegroup_ecr_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8sbook_nodegroup_role.name
}

resource "aws_iam_role" "k8sbook_op_role" {
  name = "k8sbook_op_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "k8sbook_op_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.k8sbook_op_role.name
}

resource "aws_iam_instance_profile" "k8sbook_op_profile" {
  name = "k8sbook_op_profile"
  role = aws_iam_role.k8sbook_op_role.name
}

resource "aws_iam_user" "k8sbook_batch_user" {
  name = "eks-work-batch-user"
  path = "/"
}

resource "aws_iam_access_key" "k8sbook_batch_user_key" {
  user = aws_iam_user.k8sbook_batch_user.name
}

