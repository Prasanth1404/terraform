# 1. ECR watcher role: read image digests from ECR
resource "aws_iam_role" "lwp-ecr-watcher-role-tf" {
  name = "lwp-ecr-watcher-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = {
    owner = "terraform"
  }
}

# 2. ECR read-only policy
resource "aws_iam_role_policy_attachment" "lwp-ecr-watcher-ecr-tf" {
  role       = aws_iam_role.lwp-ecr-watcher-role-tf.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 3. Link the role to the CronJob's service account
resource "aws_eks_pod_identity_association" "lwp-ecr-watcher-pia-tf" {
  cluster_name    = aws_eks_cluster.lwp-eks-tf.name
  namespace       = "vendure-ns"
  service_account = "ecr-watcher"
  role_arn        = aws_iam_role.lwp-ecr-watcher-role-tf.arn
}