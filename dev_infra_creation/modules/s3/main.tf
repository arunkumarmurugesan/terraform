resource "aws_s3_bucket" "state_store" {
  bucket        = "${var.projectname}-${var.env}-kops-statestore"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
}
    tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.env}-kops-state-store"))}"
}