resource "aws_ecs_cluster" "test-cluster" {
  name = var.cluster_name
}

data "template_file" "testapp" {
  template = file("./templates/image/image.json")
}

resource "aws_ecs_task_definition" "test-def" {
  family                   = var.task_definition_name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 3072
  container_definitions    = data.template_file.testapp.rendered
}

resource "aws_ecs_service" "test-service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.test-cluster.id
  task_definition = aws_ecs_task_definition.test-def.arn
  launch_type     = "FARGATE"
  force_new_deployment = true

 network_configuration {
    security_groups  = [aws_security_group.ecs-sg.id]
    subnets          = aws_subnet.private-subnet[*].id
    assign_public_ip = true
  }

 load_balancer {
    target_group_arn = aws_alb_target_group.myapp-tg.arn
    container_name   = "testapp"
    container_port   = 80
  } 

   depends_on = [aws_alb_listener.testapp, aws_iam_role_policy_attachment.ecs_task_execution_role]
}