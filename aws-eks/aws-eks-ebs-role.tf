# 3. EBS CSI role: lets the EBS driver create volumes for PVCs (via Pod Identity)
resource "aws_iam_role" "lwp-ebs-csi-role-tf" {
  name = "lwp-ebs-csi-role"

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

# 3.1. EBS CSI policy
resource "aws_iam_role_policy_attachment" "lwp-ebs-csi-policy-tf" {
  role       = aws_iam_role.lwp-ebs-csi-role-tf.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}