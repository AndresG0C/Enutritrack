#############################################
# IAM MODULE (AWS ACADEMY SAFE)
# SOLO REFERENCIA A LABROLE
#############################################

data "aws_iam_role" "labrole" {
  name = "LabRole"
}
