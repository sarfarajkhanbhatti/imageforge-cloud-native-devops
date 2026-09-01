resource "aws_iam_role" "imageforge_ec2" {
  name = "${local.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}


resource "aws_iam_role_policy" "imageforge_s3" {
  name = "${local.project_name}-s3-policy"
  role = aws_iam_role.imageforge_ec2.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = "${aws_s3_bucket.imageforge.arn}/images/*"
      },
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.imageforge.arn

        Condition = {
          StringLike = {
            "s3:prefix" = [
              "images/*"
            ]
          }
        }
      }
    ]
  })
}


resource "aws_iam_instance_profile" "imageforge" {
  name = "${local.project_name}-instance-profile"
  role = aws_iam_role.imageforge_ec2.name

  tags = local.common_tags
}