resource "aws_lightsail_container_service" "backup_uptime_kuma_service" {
  name  = local.name
  power = "nano"
  scale = 1
  tags = {
    version = "1.0.0"
  }

  private_registry_access {
    ecr_image_puller_role {
      is_active = true
    }
  }

  tags_all = local.tags
}

resource "aws_lightsail_container_service_deployment_version" "backup_uptime_kuma_deployment" {
  container {
    container_name = local.container_name
    image          = "${data.aws_ecr_repository.ecr_repo.repository_url}@${data.aws_ecr_image.service_image.id}"

    ports = {
      # Consistent with the port exposed by the Dockerfile and application
      3001 = "HTTP"
    }
  }

  public_endpoint {
    container_name = local.container_name
    # Consistent with the port exposed by the Dockerfile and application
    container_port = 3001

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 2
      interval_seconds    = 5
      path                = "/"
      success_codes       = "200-499"
    }
  }

  service_name = aws_lightsail_container_service.backup_uptime_kuma_service.name

}

output "public_endpoint" {
  value = aws_lightsail_container_service_deployment_version.backup_uptime_kuma_deployment.public_endpoint
}

output "container_service_private_ip" {
  value = aws_lightsail_container_service.backup_uptime_kuma_service.private_domain_name
}
