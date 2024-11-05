locals {
  readonly_policy_attachments = flatten([
    for user_name, buckets in var.user_readonly_permissions : [
      for bucket_name in buckets : {
        user_name   = user_name
        bucket_name = bucket_name
        key         = "${user_name}_${bucket_name}"
      }
    ]
  ])

  readwrite_policy_attachments = flatten([
    for user_name, buckets in var.user_readwrite_permissions : [
      for bucket_name in buckets : {
        user_name   = user_name
        bucket_name = bucket_name
        key         = "${user_name}_${bucket_name}"
      }
    ]
  ])
}

resource "aws_s3_bucket" "data_buckets" {
  for_each = toset(var.buckets)
  bucket   = each.key
}

resource "aws_iam_user" "users" {
  for_each = { for user in distinct(concat(keys(var.user_readonly_permissions), keys(var.user_readwrite_permissions))) : user => user }
  name     = each.value
}

resource "aws_iam_policy" "bucket_readonly_policy" {
  for_each = toset(var.buckets)

  name = "${each.key}-readonly"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:GetObject"],
      Resource = "arn:aws:s3:::${each.key}/*"
    }]
  })
}

resource "aws_iam_policy" "bucket_readwrite_policy" {
  for_each = toset(var.buckets)

  name = "${each.key}-readwrite"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      Resource = "arn:aws:s3:::${each.key}/*"
    }]
  })
}

resource "aws_iam_user_policy_attachment" "readonly_policy_attachments" {
  for_each = { for attachment in local.readonly_policy_attachments : attachment.key => attachment }

  user       = aws_iam_user.users[each.value.user_name].name
  policy_arn = aws_iam_policy.bucket_readonly_policy[each.value.bucket_name].arn
}

resource "aws_iam_user_policy_attachment" "readwrite_policy_attachments" {
  for_each = { for attachment in local.readwrite_policy_attachments : attachment.key => attachment }

  user       = aws_iam_user.users[each.value.user_name].name
  policy_arn = aws_iam_policy.bucket_readwrite_policy[each.value.bucket_name].arn
}
