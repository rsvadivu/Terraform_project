resource "aws_s3_bucket" "terraform-state-bucket1" {
  bucket = "rsvadivu-terraform-state-bucket1"
  

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}