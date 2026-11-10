# 1. Find the VPC created by aws-common (by its Name tag)
data "aws_vpc" "lwp-vpc" {
  filter {
    name   = "tag:Name"
    values = ["lwp-vpc"]
  }
}

#====================================================================

# 2. Find public subnet 1
data "aws_subnet" "lwp-pub-sub-1" {
  vpc_id = data.aws_vpc.lwp-vpc.id

  filter {
    name   = "tag:Name"
    values = ["lwp-pub-sub-1"]
  }
}

#====================================================================

# 3. Find public subnet 2
data "aws_subnet" "lwp-pub-sub-2" {
  vpc_id = data.aws_vpc.lwp-vpc.id

  filter {
    name   = "tag:Name"
    values = ["lwp-pub-sub-2"]
  }
}

#====================================================================

# 4. Find public subnet 3
data "aws_subnet" "lwp-pub-sub-3" {
  vpc_id = data.aws_vpc.lwp-vpc.id

  filter {
    name   = "tag:Name"
    values = ["lwp-pub-sub-3"]
  }
}