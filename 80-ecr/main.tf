resource "aws_ecr_repository" "backend" {
  name                 = "expense/backend"
  image_tag_mutability = "MUTABLE" #image tags can be overwritten

  image_scanning_configuration {
    scan_on_push = true #scan images for vulnerabilities when they are pushed to the repository
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "expense/frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
