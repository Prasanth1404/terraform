# 1. EKS cluster role: lets the EKS control plane manage AWS resources
resource "aws_iam_role" "lwp-eks-cluster-role-tf" {
  name = "lwp-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = {
    owner = "terraform"
  }
}

# 1.1. Cluster role policy
resource "aws_iam_role_policy_attachment" "lwp-cluster-policy-tf" {
  role       = aws_iam_role.lwp-eks-cluster-role-tf.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}