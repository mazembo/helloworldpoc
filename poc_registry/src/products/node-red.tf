variable "aws_region" {
    type = "string"
}

provider "aws" {
    region  = "${var.aws_region}"
}

/*====
App Load Balancer
======*/
resource "random_id" "target_group_sufix" {
  byte_length = 4
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = "alb-target-group-${random_id.target_group_sufix.hex}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0bae5a0b8ca9f38a2"
  target_type = "ip"

  depends_on        = ["aws_alb.alb_node-red"]
  lifecycle {
    create_before_destroy = true
  }
}

/* security group for ALB */
resource "aws_security_group" "alb_inbound_sg" {
  name        = "${random_id.target_group_sufix.hex}-alb-inbound-sg"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = "vpc-0bae5a0b8ca9f38a2"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${random_id.target_group_sufix.hex}-alb-inbound-sg"
  }
}

resource "aws_alb" "alb_node-red" {
  name            = "node-red-${random_id.target_group_sufix.hex}"
  subnets         = ["subnet-0650bb47027305e2e", "subnet-02069874302a13953"]
  security_groups = ["sg-08d33891ab3862420", "${aws_security_group.alb_inbound_sg.id}"]
}

resource "aws_alb_listener" "node-red" {
  load_balancer_arn = "${aws_alb.alb_node-red.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on        = ["aws_alb_target_group.alb_target_group"]

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }
}

/*
* IAM service role
*/

/*====
ECS service
======*/

/* Security Group for ECS */
resource "aws_security_group" "ecs_service" {
  vpc_id      = "vpc-0bae5a0b8ca9f38a2"
  name        = "${random_id.target_group_sufix.hex}-ecs-service-sg"
  description = "Allow egress from container"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${random_id.target_group_sufix.hex}-ecs-service-sg"
  }
}

resource "aws_ecs_service" "node-red" {
  name            = "${random_id.target_group_sufix.hex}-node-red"
  task_definition = "arn:aws:ecs:eu-central-1:255639296009:task-definition/sc-poc_node-red:4"
  desired_count   = 1
  launch_type     = "FARGATE"
  cluster         = "arn:aws:ecs:eu-central-1:255639296009:cluster/sc-poc-ecs-cluster"
  //depends_on      = ["aws_iam_role_policy.ecs_service_role_policy"]

  network_configuration {
    security_groups = ["sg-08d33891ab3862420", "${aws_security_group.ecs_service.id}"]
    subnets         = ["subnet-0a6f747716b338d7b", "subnet-08e3c2f6b4cd1a942"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    container_name   = "node-red"
    container_port   = "1880"
  }

  depends_on = ["aws_alb_target_group.alb_target_group"]
}

output webaddress {
    value = "${format("http://%s",aws_alb.alb_node-red.dns_name)}"
}
