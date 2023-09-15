locals {

  name           = var.project
  region         = var.region
  container_name = var.container_name

  tags = {
    name       = "${var.project}"
    managed-by = "terraform"
  }
}