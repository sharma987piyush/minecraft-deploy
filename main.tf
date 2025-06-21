terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#--------------------------------------------------------------------------------------------------
# vpc
#--------------------------------------------------------------------------------------------------

resource "aws_vpc" "mine" {
  cidr_block = "10.0.0.0/16"
    tags = {
        Name = "mine-vpc"
    }
}

#--------------------------------------------------------------------------------------------------
# subnets
#--------------------------------------------------------------------------------------------------

resource "aws_subnet" "mine-pvt-1" {
  vpc_id     = aws_vpc.mine.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "pvt-1"
  }
}

resource "aws_subnet" "mine-pvt-2" {
  vpc_id     = aws_vpc.mine.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "pvt-2"
  }
}

resource "aws_subnet" "mine-pub-1" {
  vpc_id     = aws_vpc.mine.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "pub-1"
  }
}

resource "aws_subnet" "mine-pub-2" {
  vpc_id     = aws_vpc.mine.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "pub-2"
  }
}

#--------------------------------------------------------------------------------------------------
# internet gateway
#--------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "mine-igw" {
  vpc_id = aws_vpc.mine.id

  tags = {
    Name = "mine-igw"
  }
}

#--------------------------------------------------------------------------------------------------
# route tables  
#--------------------------------------------------------------------------------------------------

resource "aws_route_table" "mine-pub-rt" {
  vpc_id = aws_vpc.mine.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mine-igw.id
  }
}

#--------------------------------------------------------------------------------------------------
# route table association
#--------------------------------------------------------------------------------------------------

resource "aws_route_table_association" "mine-pub-1" {
  subnet_id      = aws_subnet.mine-pub-1.id
  route_table_id = aws_route_table.mine-pub-rt.id
}

resource "aws_route_table_association" "mine-pub-2" {
  subnet_id      = aws_subnet.mine-pub-2.id
  route_table_id = aws_route_table.mine-pub-rt.id
}

#--------------------------------------------------------------------------------------------------
# NLB Security Group
#--------------------------------------------------------------------------------------------------
resource "aws_security_group" "nlb_sg" {
  name        = "nlb-security-group"
  vpc_id      = aws_vpc.mine.id 

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nlb-sg"
  }
}

#--------------------------------------------------------------------------------------------------
# EC2 Nodes Security Group
#--------------------------------------------------------------------------------------------------
resource "aws_security_group" "node_sg" {
  name        = "eks-node-security-group"
  vpc_id      = aws_vpc.mine.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "node-sg"
  }
}

#--------------------------------------------------------------------------------------------------
# Node Security Group
#--------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "allow_traffic_from_nlb" {
  type                     = "ingress"
  from_port                = 0 
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.nlb_sg.id 
}


resource "aws_security_group_rule" "allow_traffic_from_eks_master" {
  type                     = "ingress"
  from_port                = 1025 
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_eks_cluster.my_game_cluster.vpc_config[0].cluster_security_group_id 
}

resource "aws_security_group_rule" "allow_self_traffic" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.node_sg.id
  self              = true 
}

#--------------------------------------------------------------------------------------------------
# eip for nat gateway
#--------------------------------------------------------------------------------------------------

resource "aws_eip" "eip-a" {
  domain   = "vpc"
  tags = {
    Name = "eip-a"
  }
}

resource "aws_eip" "eip-b" {
  domain   = "vpc"
  tags = {
    Name = "eip-b"
  }
}

#--------------------------------------------------------------------------------------------------
# network load balancer
#--------------------------------------------------------------------------------------------------

resource "aws_lb" "nlb" {
  name               = "mine-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.mine-pub-1.id, aws_subnet.mine-pub-2.id]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
}
#--------------------------------------------------------------------------------------------------
# lb target group
#--------------------------------------------------------------------------------------------------

resource "aws_lb_target_group" "lb-target" {
  name        = "game-server-tg"
  port        = 25565              
  protocol    = "TCP"              
  vpc_id      = aws_vpc.mine.id
  target_type = "instance"         


  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "traffic-port"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  stickiness {
    type    = "source_ip" 
    enabled = true
  }
}

#--------------------------------------------------------------------------------------------------
# lb listener
#--------------------------------------------------------------------------------------------------

resource "aws_lb_listener" "mine-lb-listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 25565
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target.arn
  }
}

#--------------------------------------------------------------------------------------------------
# nat gateway
#--------------------------------------------------------------------------------------------------

resource "aws_nat_gateway" "nat-1" {
  allocation_id = aws_eip.eip-a.id
  subnet_id     = aws_subnet.mine-pub-1.id

  tags = {
    Name = "gw-NAT"
  }

  depends_on = [aws_internet_gateway.mine-igw]
}

resource "aws_nat_gateway" "nat-2" {
  allocation_id = aws_eip.eip-b.id
  subnet_id     = aws_subnet.mine-pub-2.id

  tags = {
    Name = "ngw"
  }

  depends_on = [aws_internet_gateway.mine-igw]
}

#--------------------------------------------------------------------------------------------------
# route table for private subnets
#--------------------------------------------------------------------------------------------------

resource "aws_route_table" "mine-pvt-rt-1" {
  vpc_id = aws_vpc.mine.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-1.id
  }
}

resource "aws_route_table" "mine-pvt-rt-2" {
  vpc_id = aws_vpc.mine.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-2.id
  }
}

#--------------------------------------------------------------------------------------------------
# route table association for private subnets
#--------------------------------------------------------------------------------------------------

resource "aws_route_table_association" "mine-pvt-1" {
  subnet_id      = aws_subnet.mine-pvt-1.id
  route_table_id = aws_route_table.mine-pvt-rt-1.id
}

resource "aws_route_table_association" "mine-pvt-2" {
  subnet_id      = aws_subnet.mine-pvt-2.id
  route_table_id = aws_route_table.mine-pvt-rt-2.id
}

#--------------------------------------------------------------------------------------------------
# global accelerator
#--------------------------------------------------------------------------------------------------

resource "aws_globalaccelerator_accelerator" "game-ga" {
  name            = "game-accelerator"
  ip_address_type = "IPV4"
  enabled         = true
  tags = {
    Name = "game-accelerator"
  }
}

#--------------------------------------------------------------------------------------------------
# global accelerator listener 
#--------------------------------------------------------------------------------------------------
resource "aws_globalaccelerator_listener" "ga-listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.game-ga.arn
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 25565
    to_port   = 25565
  }
}
#--------------------------------------------------------------------------------------------------
# global accelerator endpoint group
#--------------------------------------------------------------------------------------------------

resource "aws_globalaccelerator_endpoint_group" "ga-endpoint" {
  listener_arn = aws_globalaccelerator_listener.ga-listener.arn
  endpoint_configuration {
    endpoint_id = aws_lb.nlb.arn
    weight      = 100
  }
}

#--------------------------------------------------------------------------------------------------
# iam role for EC2 
#--------------------------------------------------------------------------------------------------

resource "aws_iam_role" "iam-ec2-role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

#--------------------------------------------------------------------------------------------------
# finding the policies
#--------------------------------------------------------------------------------------------------

data "aws_iam_policy" "eks_worker_node_policy" {
  name = "AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "ecr_read_only_policy" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "cni_policy" {
  name = "AmazonEKS_CNI_Policy"
}

#--------------------------------------------------------------------------------------------------
# attaching the policies to the role
#--------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "node_worker_attachment" {
  role       = aws_iam_role.iam-ec2-role.name
  policy_arn = data.aws_iam_policy.eks_worker_node_policy.arn
}

resource "aws_iam_role_policy_attachment" "node_ecr_attachment" {
  role       = aws_iam_role.iam-ec2-role.name
  policy_arn = data.aws_iam_policy.ecr_read_only_policy.arn
}

resource "aws_iam_role_policy_attachment" "node_cni_attachment" {
  role       = aws_iam_role.iam-ec2-role.name
  policy_arn = data.aws_iam_policy.cni_policy.arn
}

#--------------------------------------------------------------------------------------------------
# IAM role for EKS
#--------------------------------------------------------------------------------------------------

resource "aws_iam_role" "iam-eks-role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

}

#--------------------------------------------------------------------------------------------------
# Finding the eks cluster policy
#--------------------------------------------------------------------------------------------------

data "aws_iam_policy" "eks_cluster_policy" {
  name = "AmazonEKSClusterPolicy"
}

#--------------------------------------------------------------------------------------------------
# Attaching the eks cluster policy to the iam role
#--------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "eks_cluster_attachment" {
  role       = aws_iam_role.iam-eks-role.name
  policy_arn = data.aws_iam_policy.eks_cluster_policy.arn
}

#--------------------------------------------------------------------------------------------------
# ecr repository
#--------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "ecr" {
  name                 = "mine-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#--------------------------------------------------------------------------------------------------
# eks cluster
#--------------------------------------------------------------------------------------------------

resource "aws_eks_cluster" "my_game_cluster" {
  name     = "my-minecraft-cluster"
  version  = "1.29" 
  

  role_arn = aws_iam_role.iam-eks-role.arn 


  vpc_config {

    subnet_ids = [
      aws_subnet.mine-pub-1.id,
      aws_subnet.mine-pub-2.id,
      aws_subnet.mine-pvt-1.id,
      aws_subnet.mine-pvt-2.id
    ]

    
    endpoint_public_access = true 
  }


  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_attachment,
  ]
}

#--------------------------------------------------------------------------------------------------
# eks node group
#--------------------------------------------------------------------------------------------------

resource "aws_eks_node_group" "my_game_node_group" {
  cluster_name    = aws_eks_cluster.my_game_cluster.name
  node_group_name = "my-minecraft-node-group"
  node_role_arn   = aws_iam_role.iam-ec2-role.arn
  subnet_ids      = [aws_subnet.mine-pvt-1.id, aws_subnet.mine-pvt-2.id]

  instance_types = ["m5.large"]

  ami_type = "AL2_x86_64"

  disk_size = 20 


  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_attachment,
    aws_iam_role_policy_attachment.node_ecr_attachment,
    aws_iam_role_policy_attachment.node_cni_attachment,
  ]
}