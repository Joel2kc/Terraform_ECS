resource "aws_ecr_repository" "ecr" {
  name = "terraform-ecr"
  image_tag_mutability = "IMMUTABLE"
  force_delete = true
  tags = {
    Name = var.ecr_name
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole-terra" {
  name = "ecsTaskExecutionRole-terra"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}



resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole-terra" {
 role      = aws_iam_role.ecsTaskExecutionRole-terra.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}