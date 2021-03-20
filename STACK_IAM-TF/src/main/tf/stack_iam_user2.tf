resource "aws_iam_user" "user" {
  name          = "stackuser1"
  path          = "/"
  force_destroy = true
  permissions_boundary = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_login_profile" "log-prof" {
  user    = aws_iam_user.user.name
  pgp_key = "keybase:habeeboba"
}

output "password" {
  value = aws_iam_user_login_profile.log-prof.encrypted_password
}

resource "aws_iam_group" "group" {
  name = "stack-group"
}

resource "aws_iam_policy" "policy" {
  name        = "stack-ec2-iam-s3"
  description = "A policy that gives ec2, iam, s3 access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ec2:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "iam:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "stack-attach" {
  name       = "stack-attachment"
  groups     = [aws_iam_group.group.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_group_membership" "team" {
  name = "stack-group-membership"

  users = [
    aws_iam_user.user.name,
  ]

  group = aws_iam_group.group.name
}