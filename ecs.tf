resource "aws_ecs_cluster" "test-cluster" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "test-def" {
  family                   = var.task_definition_name
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole-terra.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 3072
  container_definitions   = <<DEFINITION
  [
    {
      "name": "flask-app",
      "image": "956640667068.dkr.ecr.eu-west-2.amazonaws.com/terraform-ecr",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000,
          "protocol": "tcp",
          "appProtocol" :"http"
        }
      ],
      "memory": 3072,
      "cpu": 1024,
      "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log.name}",
          "awslogs-region": "eu-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  DEFINITION

}

resource "aws_cloudwatch_log_group" "log" {
  name = "log"

  tags = {
    Environment = "production"
    Application = "flask-app"
  }
}

resource "aws_ecs_service" "test-service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.test-cluster.id
  task_definition = aws_ecs_task_definition.test-def.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  force_new_deployment = true

 network_configuration {
    security_groups  = [aws_security_group.ecs-sg.id]
    subnets          = [aws_subnet.public-subnet.id,aws_subnet.private-subnet.id]
    assign_public_ip = true
  }

 load_balancer {
    target_group_arn = aws_alb_target_group.myapp-tg.arn
    container_name   = "flask-app"
    container_port   = 5000
  } 

   depends_on = [aws_alb_listener.testapp, aws_iam_role_policy_attachment.ecsTaskExecutionRole-terra]
}