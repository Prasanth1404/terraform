# 1. EKS cluster (Auto Mode OFF, public subnets only)
resource "aws_eks_cluster" "lwp-eks-tf" {
  name     = local.cluster_name
  version  = "1.36"
  role_arn = aws_iam_role.lwp-eks-cluster-role-tf.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.lwp-pub-sub-1-tf.id,
      aws_subnet.lwp-pub-sub-2-tf.id,
      aws_subnet.lwp-pub-sub-3-tf.id,
    ]
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true # the user running terraform becomes admin
  }

  tags = {
    owner = "terraform"
  }

  depends_on = [aws_iam_role_policy_attachment.lwp-cluster-policy-tf]
}