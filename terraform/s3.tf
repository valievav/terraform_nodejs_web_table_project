# s3 bucket
resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket = "project-nodejs-website-2025"

  tags = {
    Name        = "project-nodejs-website-2025"
    Environment = "dev"
  }
}

# s3 object to populate bucket with files
resource "aws_s3_object" "tf_s3_object" {
  bucket = aws_s3_bucket.tf_s3_bucket.bucket
  for_each = fileset(var.path_to_img_folder, "**")  # get all files in the directory and subdir
  key    = "images/${each.key}"  # file names
  source = "${var.path_to_img_folder}/${each.key}"
}
