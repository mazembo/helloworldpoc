resource "aws_ecs_cluster" "helloworld" {
  name = "helloworld"
  capacity_providers = "FARGATE"

  setting {
    name="containerInsights"
    value="enabled"
  }
}

resource "aws_ecs_service" "helloworld" {
  name            = "helloworld"
  cluster         = "${aws_ecs_cluster.helloworld.id}"
  task_definition = "${aws_ecs_task_definition.helloworld.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = ["sg-766f3f1b"]
    subnets         = ["subnet-8b79f3c6","subnet-c9d594b2","subnet-f4ae809d"]
  }
}


resource "aws_ecs_task_definition" "helloworld" {
  family                    = "helloworld"
  container_definitions     = "${file("task-definitions/helloworld.json")}"
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = "${var.fargate_cpu}"
  memory                    = "${var.fargate_memory}"
  execution_role_arn        = "arn:aws:iam::717206073145:role/Administrators"
  task_role_arn             = "arn:aws:iam::717206073145:role/Administrators"

  volume {
    name = "helloworld-storage"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
    }
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-3a, eu-west-3b, eu-west-3c]"
  }
}

