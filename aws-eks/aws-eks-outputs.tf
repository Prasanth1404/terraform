# 1. Cluster name
output "cluster_name" {
  value = aws_eks_cluster.lwp-eks-tf.name
}

# 2. Command to connect kubectl
output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ap-south-1 --name ${aws_eks_cluster.lwp-eks-tf.name}"
}

# 3. VPC ID
output "vpc_id" {
  value = aws_vpc.lwp-vpc-tf.id
}
