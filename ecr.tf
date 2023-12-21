resource "aws_ecr_repository" "ecr" {
  name = "terraform-ecr"
  tags = {
    Name = var.ecr_name
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "terraform_ecs_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
 role      = aws_iam_role.ecsTaskExecutionRole.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}