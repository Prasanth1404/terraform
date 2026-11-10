# 2. Managed node group (public subnets only, so every node can join)
resource "aws_eks_node_group" "lwp-nodes-tf" {
  cluster_name    = aws_eks_cluster.lwp-eks-tf.name
  node_group_name = "lwp-nodes"
  node_role_arn   = aws_iam_role.lwp-eks-node-role-tf.arn

  subnet_ids = [
    aws_subnet.lwp-pub-sub-1-tf.id,
    aws_subnet.lwp-pub-sub-2-tf.id,
    aws_subnet.lwp-pub-sub-3-tf.id,
  ]

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.large"]
  disk_size      = 20

  scaling_config {
    desired_size = 3
    min_size     = 3
    max_size     = 4
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    owner = "terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lwp-node-worker-policy-tf,
    aws_iam_role_policy_attachment.lwp-node-cni-policy-tf,
    aws_iam_role_policy_attachment.lwp-node-ecr-policy-tf,
    aws_eks_addon.lwp-vpc-cni-tf,
    aws_eks_addon.lwp-kube-proxy-tf,
    aws_eks_addon.lwp-pod-identity-tf,
  ]
}