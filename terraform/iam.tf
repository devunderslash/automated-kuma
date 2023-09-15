data "aws_iam_policy_document" "ecr_access_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_lightsail_container_service.backup_uptime_kuma_service.private_registry_access[0].ecr_image_puller_role[0].principal_arn]
    }

    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
  }
}

resource "aws_ecr_repository_policy" "lightsail_access_policy" {
  repository = data.aws_ecr_repository.ecr_repo.name
  policy     = data.aws_iam_policy_document.ecr_access_policy_document.json
}
