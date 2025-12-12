module "private_bucket" {
  source        = "../../../modules/private_bucket"
  bucket_name   = "terraform-state-${var.env}-${var.random_suffix}"
  force_destroy = true
}
