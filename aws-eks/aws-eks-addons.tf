# 1. VPC CNI: gives every pod an IP from the VPC (needed before nodes)
resource "aws_eks_addon" "lwp-vpc-cni-tf" {
  cluster_name                = aws_eks_cluster.lwp-eks-tf.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
}

#================================================================================

# 2. kube-proxy: service-to-pod networking (needed before nodes)
resource "aws_eks_addon" "lwp-kube-proxy-tf" {
  cluster_name                = aws_eks_cluster.lwp-eks-tf.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
}

#================================================================================

# 3. Pod Identity Agent: gives pods AWS permissions (needed by EBS CSI)
resource "aws_eks_addon" "lwp-pod-identity-tf" {
  cluster_name                = aws_eks_cluster.lwp-eks-tf.name
  addon_name                  = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
}

#================================================================================

# 4. CoreDNS: DNS inside the cluster (runs on nodes, so waits for them)
resource "aws_eks_addon" "lwp-coredns-tf" {
  cluster_name                = aws_eks_cluster.lwp-eks-tf.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_node_group.lwp-nodes-tf]
}

#================================================================================

# 5. EBS CSI driver: creates EBS volumes for PVCs (MySQL, product images)
resource "aws_eks_addon" "lwp-ebs-csi-tf" {
  cluster_name                = aws_eks_cluster.lwp-eks-tf.name
  addon_name                  = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE"

  pod_identity_association {
    role_arn        = aws_iam_role.lwp-ebs-csi-role-tf.arn
    service_account = "ebs-csi-controller-sa"
  }

  depends_on = [
    aws_eks_node_group.lwp-nodes-tf,
    aws_eks_addon.lwp-pod-identity-tf,
  ]
}

#================================================================================

# 6. metrics-server: enables "kubectl top"
resource "aws_eks_addon" "lwp-metrics-server-tf" {
  cluster_name                = aws_eks_cluster.lwp-eks-tf.name
  addon_name                  = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_node_group.lwp-nodes-tf]
}

#================================================================================

# 7. cert-manager: free SSL from Let's Encrypt (remove if not available in your region)
resource "aws_eks_addon" "lwp-cert-manager-tf" {
  cluster_name                = aws_eks_cluster.lwp-eks-tf.name
  addon_name                  = "cert-manager"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_node_group.lwp-nodes-tf]
}
