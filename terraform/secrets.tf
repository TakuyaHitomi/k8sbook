data "aws_secretsmanager_secret" "k8sbook_secret" {
  arn = "arn:aws:secretsmanager:ap-northeast-1:796173159873:secret:secretManagerTest-IeJWnp"
}

data "aws_secretsmanager_secret_version" "k8sbook_secret_version" {
  secret_id = data.aws_secretsmanager_secret.k8sbook_secret.id
}
