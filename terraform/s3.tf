resource "aws_s3_bucket" "k8sbook_s3_bucket" {
  bucket = "dev-puzzle-k8sbook"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "k8sbook_s3_bucket_policy" {
  bucket = aws_s3_bucket.k8sbook_s3_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "k8sbook_s3_bucket_policy",
  "Statement": [
    {
      "Sid": "AllowGetObjectFromCloudFront",
      "Effect": "Allow",
      "Principal": { "AWS": "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}" },
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.k8sbook_s3_bucket.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "k8sbook_s3_batch_bucket" {
  bucket = "dev-puzzle-k8sbook-batch"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "k8sbook_s3_batch_bucket_policy" {
  bucket = aws_s3_bucket.k8sbook_s3_batch_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "k8sbook_s3_batch_bucket_policy",
  "Statement": [
    {
      "Sid": "AllowGetDeleteObjectFromBatch",
      "Effect": "Allow",
      "Principal": { "AWS": "${aws_iam_user.k8sbook_batch_user.arn}" },
      "Action": [ "s3:GetObject", "s3:DeleteObject" ],
      "Resource": "${aws_s3_bucket.k8sbook_s3_batch_bucket.arn}/*"
    },
    {
      "Sid": "AllowListBucketFromBatch",
      "Effect": "Allow",
      "Principal": { "AWS": "${aws_iam_user.k8sbook_batch_user.arn}" },
      "Action": "s3:ListBucket",
      "Resource": "${aws_s3_bucket.k8sbook_s3_batch_bucket.arn}"
    }
  ]
}
POLICY
}
