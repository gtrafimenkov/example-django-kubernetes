# SPDX-License-Identifier: MIT
# Copyright (c) 2020 Gennady Trafimenkov

resource "aws_eks_cluster" "main" {
  name     = var.name
  role_arn = aws_iam_role.cluster-role.arn

  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]
    subnet_ids         = aws_subnet.public.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]

  tags = var.tags
}

resource "aws_eks_node_group" "g1" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "g1"
  node_role_arn   = aws_iam_role.nodes-role.arn
  subnet_ids      = aws_subnet.public.*.id
  disk_size       = 20
  instance_types  = ["t3a.small"]


  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = var.tags
}
