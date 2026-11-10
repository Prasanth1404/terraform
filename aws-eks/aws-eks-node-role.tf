# 2. Node role: used by the EC2 worker nodes
resource "aws_iam_role" "lwp-eks-node-role-tf" {
  name = "lwp-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    owner = "terraform"
  }
}

# 2.1. Node policy: join the cluster
resource "aws_iam_role_policy_attachment" "lwp-node-worker-policy-tf" {
  role       = aws_iam_role.lwp-eks-node-role-tf.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# 2.2. Node policy: pod networking (VPC CNI)
resource "aws_iam_role_policy_attachment" "lwp-node-cni-policy-tf" {
  role       = aws_iam_role.lwp-eks-node-role-tf.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# 2.3. Node policy: pull images from ECR
resource "aws_iam_role_policy_attachment" "lwp-node-ecr-policy-tf" {
  role       = aws_iam_role.lwp-eks-node-role-tf.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}