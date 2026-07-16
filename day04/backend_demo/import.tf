resource "aws_s3_bucket" "imported" {
  bucket = "terraweek-2026-state-bucket-sakshi"
}

import {
  to = aws_s3_bucket.imported
  id = "terraweek-2026-state-bucket-sakshi"
}
