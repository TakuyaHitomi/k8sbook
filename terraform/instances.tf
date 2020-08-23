data "template_file" "k8sbook_op_template" {
  template = file("./userdata.tpl")
}

resource "aws_instance" "k8sbook_op" {
  ami                  = var.op_image_id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.k8sbook_op_profile.name
  user_data_base64     = base64encode(data.template_file.k8sbook_op_template.rendered)
  subnet_id            = aws_subnet.op_subnet.id

  vpc_security_group_ids = [
    aws_security_group.op_security_group.id
  ]

  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }
}
