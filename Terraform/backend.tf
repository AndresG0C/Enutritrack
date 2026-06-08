# BACKEND LOCAL PARA AWS ACADEMY LEARNER LAB
# No requiere S3, usa archivo local

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
