data "aws_ecr_repository" "ecr_repo" {
  name = local.container_name
}

data "aws_ecr_image" "service_image" {
  repository_name = local.container_name
  most_recent     = true
}
