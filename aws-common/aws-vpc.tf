# 1. VPC
resource "aws_vpc" "lwp-vpc-tf" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true # EKS nodes need DNS to find the cluster
  enable_dns_hostnames = true # EKS nodes need DNS hostnames to join

  tags = {
    Name  = "lwp-vpc"
    owner = "terraform"
  }
}

#================================================================================

# 2. Internet Gateway
resource "aws_internet_gateway" "lwp-gw-tf" {
  vpc_id = aws_vpc.lwp-vpc-tf.id

  tags = {
    Name  = "lwp-gw"
    owner = "terraform"
  }
}

#================================================================================

# 3. Public subnet 1 (EKS cluster + nodes)
resource "aws_subnet" "lwp-pub-sub-1-tf" {
  vpc_id                  = aws_vpc.lwp-vpc-tf.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                          = "lwp-pub-sub-1"
    owner                                         = "terraform"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

# 4. Public subnet 2 (EKS cluster + nodes)
resource "aws_subnet" "lwp-pub-sub-2-tf" {
  vpc_id                  = aws_vpc.lwp-vpc-tf.id
  cidr_block              = "172.16.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                                          = "lwp-pub-sub-2"
    owner                                         = "terraform"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

# 5. Public subnet 3 (EKS cluster + nodes)
resource "aws_subnet" "lwp-pub-sub-3-tf" {
  vpc_id                  = aws_vpc.lwp-vpc-tf.id
  cidr_block              = "172.16.5.0/24"
  availability_zone       = "ap-south-1c"
  map_public_ip_on_launch = true

  tags = {
    Name                                          = "lwp-pub-sub-3"
    owner                                         = "terraform"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}

#================================================================================

# 6. Private subnet 1 (not used by EKS now: no NAT, so no internet)
resource "aws_subnet" "lwp-pri-sub-1-tf" {
  vpc_id            = aws_vpc.lwp-vpc-tf.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name  = "lwp-pri-sub-1"
    owner = "terraform"
  }
}

# 7. Private subnet 2 (not used by EKS now)
resource "aws_subnet" "lwp-pri-sub-2-tf" {
  vpc_id            = aws_vpc.lwp-vpc-tf.id
  cidr_block        = "172.16.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name  = "lwp-pri-sub-2"
    owner = "terraform"
  }
}

# 8. Private subnet 3 (not used by EKS now)
resource "aws_subnet" "lwp-pri-sub-3-tf" {
  vpc_id            = aws_vpc.lwp-vpc-tf.id
  cidr_block        = "172.16.6.0/24"
  availability_zone = "ap-south-1c"

  tags = {
    Name  = "lwp-pri-sub-3"
    owner = "terraform"
  }
}

#================================================================================

# 9. Public route table (internet through the Internet Gateway)
resource "aws_route_table" "lwp-pub-rt-tf" {
  vpc_id = aws_vpc.lwp-vpc-tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lwp-gw-tf.id
  }

  tags = {
    Name  = "lwp-pub-rt"
    owner = "terraform"
  }
}

#================================================================================

# 10. Private route table (no internet route: add a NAT Gateway later if needed)
resource "aws_route_table" "lwp-pri-rt-tf" {
  vpc_id = aws_vpc.lwp-vpc-tf.id

  tags = {
    Name  = "lwp-pri-rt"
    owner = "terraform"
  }
}

#================================================================================

# 11. Associate public subnet 1
resource "aws_route_table_association" "lwp-pub-ass-1-tf" {
  subnet_id      = aws_subnet.lwp-pub-sub-1-tf.id
  route_table_id = aws_route_table.lwp-pub-rt-tf.id
}

# 12. Associate public subnet 2
resource "aws_route_table_association" "lwp-pub-ass-2-tf" {
  subnet_id      = aws_subnet.lwp-pub-sub-2-tf.id
  route_table_id = aws_route_table.lwp-pub-rt-tf.id
}

# 13. Associate public subnet 3
resource "aws_route_table_association" "lwp-pub-ass-3-tf" {
  subnet_id      = aws_subnet.lwp-pub-sub-3-tf.id
  route_table_id = aws_route_table.lwp-pub-rt-tf.id
}

#================================================================================

# 14. Associate private subnet 1
resource "aws_route_table_association" "lwp-pri-ass-1-tf" {
  subnet_id      = aws_subnet.lwp-pri-sub-1-tf.id
  route_table_id = aws_route_table.lwp-pri-rt-tf.id
}

# 15. Associate private subnet 2
resource "aws_route_table_association" "lwp-pri-ass-2-tf" {
  subnet_id      = aws_subnet.lwp-pri-sub-2-tf.id
  route_table_id = aws_route_table.lwp-pri-rt-tf.id
}

# 16. Associate private subnet 3
resource "aws_route_table_association" "lwp-pri-ass-3-tf" {
  subnet_id      = aws_subnet.lwp-pri-sub-3-tf.id
  route_table_id = aws_route_table.lwp-pri-rt-tf.id
}

#================================================================================

# 17. Public security group (for your own EC2 like a bastion; EKS makes its own)
resource "aws_security_group" "lwp-sg-tf" {
  name        = "lwp-sg"
  description = "lwp-sg"
  vpc_id      = aws_vpc.lwp-vpc-tf.id

  tags = {
    Name  = "lwp-sg"
    owner = "terraform"
  }
}

# 18. Public SG: allow everything from my IP only
resource "aws_vpc_security_group_ingress_rule" "inb" {
  security_group_id = aws_security_group.lwp-sg-tf.id
  cidr_ipv4         = "223.181.211.68/32"
  ip_protocol       = "-1"
}

# 19. Public SG: allow all outgoing
resource "aws_vpc_security_group_egress_rule" "out" {
  security_group_id = aws_security_group.lwp-sg-tf.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#================================================================================

# 20. Private security group (for future private resources)
resource "aws_security_group" "lwp-pri-sg-tf" {
  name        = "lwp-pri-sg"
  description = "lwp-pri-sg"
  vpc_id      = aws_vpc.lwp-vpc-tf.id

  tags = {
    Name  = "lwp-pri-sg"
    owner = "terraform"
  }
}

# 21. Private SG: allow traffic from the whole VPC
resource "aws_vpc_security_group_ingress_rule" "pri-inb" {
  security_group_id = aws_security_group.lwp-pri-sg-tf.id
  cidr_ipv4         = aws_vpc.lwp-vpc-tf.cidr_block
  ip_protocol       = "-1"
}

# 22. Private SG: allow all outgoing
resource "aws_vpc_security_group_egress_rule" "pri-out" {
  security_group_id = aws_security_group.lwp-pri-sg-tf.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
