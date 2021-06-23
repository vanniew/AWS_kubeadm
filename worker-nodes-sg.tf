
resource "aws_security_group" "worker-nodes" {
  name        = "${var.cluster_name}-worker-nodes"
  description = "Enable mandatory communication between worker nodes"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.cluster_name}-worker_nodes"
  }
}

resource "aws_security_group_rule" "all_tcp_worker_nodes" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.worker-nodes.id
  source_security_group_id = aws_security_group.master-nodes.id
}

resource "aws_security_group_rule" "all_udp_worker_nodes" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  security_group_id = aws_security_group.worker-nodes.id
  source_security_group_id = aws_security_group.master-nodes.id
}

resource "aws_security_group_rule" "all_internal_worker_nodes" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = aws_security_group.worker-nodes.id
  self              = true
}

resource "aws_security_group_rule" "all_outbound_worker" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker-nodes.id
}
