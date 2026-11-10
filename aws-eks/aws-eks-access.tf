# 1. Access entry for the root user (so the AWS console can show nodes)
# The terraform user (sgprasanth-terraform) is already admin through the cluster's bootstrap setting.
resource "aws_eks_access_entry" "lwp-root-access-tf" {
  cluster_name  = aws_eks_cluster.lwp-eks-tf.name
  principal_arn = "arn:aws:iam::948609688539:root"
  type          = "STANDARD"
}

# 2. Give the root user cluster admin
resource "aws_eks_access_policy_association" "lwp-root-admin-tf" {
  cluster_name  = aws_eks_cluster.lwp-eks-tf.name
  principal_arn = "arn:aws:iam::948609688539:root"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.lwp-root-access-tf]
}
