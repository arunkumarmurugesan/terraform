#Bastion Role
resource "aws_iam_role" "bastion_role" {
  name = "${var.projectname}-${var.env}-bastion-role"
  path = "/"
  description = "Allows EC2 to manage clusters on your behalf"
assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com",
        "Service": "es.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = "${merge(
    var.tags,
    map(
        "Name", "${var.projectname}-${var.env}-bastion-role"
    )
  )}"
}
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.projectname}-${var.env}-bastion-iam-roles"
  role = "${aws_iam_role.bastion_role.name}"
}

resource "aws_iam_role_policy" "custom-allow-policy" {
  name        = "${var.projectname}-${var.env}-bastion-policy-allow"
  role        = "${aws_iam_role.bastion_role.name}"
  #description = "Full Access to S3 except Delete Operations"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*", 
        "es:*",
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user" "app01_user" {
  count = var.iam_create_user ? 1 : 0
  name                 = "cloudmgmt_app_user"
  path                 = "/"

}

resource "aws_iam_user_policy" "app01_user_managed_policy_kms" {
  count = var.iam_create_user ? 1 : 0
  name = "app-kms-admin-policy"
  user = "${aws_iam_user.app01_user[0].name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "app01_user_managed_policy_s3" {
  count = var.iam_create_user ? 1 : 0
  user       = "${aws_iam_user.app01_user[0].name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "app01_user_managed_policy_ecr" {
  count = var.iam_create_user ? 1 : 0
  user       = "${aws_iam_user.app01_user[0].name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_user_policy_attachment" "app01_user_managed_policy_es" {
  count = var.iam_create_user ? 1 : 0
  user       = "${aws_iam_user.app01_user[0].name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
}

resource "aws_iam_access_key" "app01_user_keys" {
  count = var.iam_create_user ? 1 : 0
  user    = "${aws_iam_user.app01_user[0].name}"
}

resource "aws_iam_user" "app02_user" {
  count = var.iam_create_user ? 1 : 0
  name                 = "cfssl_app_user"
  path                 = "/"
}

resource "aws_iam_user_policy" "app02_user_managed_policy_kms" {
  count = var.iam_create_user ? 1 : 0
  name = "app-kms-admin-policy"
  user = "${aws_iam_user.app02_user[0].name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "app02_user_access_keys" {
  
  count = var.iam_create_user ? 1 : 0
  user    = "${aws_iam_user.app02_user[0].name}"
}

resource "aws_iam_user" "app03_user" {
  count = var.iam_create_user ? 1 : 0
  name                 = "operator_app_user"
  path                 = "/"
}

resource "aws_iam_user_policy" "app03_user_managed_policy_kms" {
  count = var.iam_create_user ? 1 : 0
  name = "app-kms-admin-policy"
  user = "${aws_iam_user.app03_user[0].name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_user_policy_attachment" "app03_user_managed_policy_s3" {
  count = var.iam_create_user ? 1 : 0
  user       = "${aws_iam_user.app03_user[0].name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "app03_user_managed_policy_ecr" {
  count = var.iam_create_user ? 1 : 0
  user       = "${aws_iam_user.app03_user[0].name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_access_key" "app03_user_access_keys" {
  count = var.iam_create_user ? 1 : 0
  user    = "${aws_iam_user.app03_user[0].name}"
}

resource "aws_iam_user" "velero_user" {
  count = var.iam_create_user ? 1 : 0
  name                 = "velero_app_user"
  path                 = "/"
}

resource "aws_iam_user_policy" "velero_user_managed_policy_kms" {
  count = var.iam_create_user ? 1 : 0
  name = "app-kms-admin-policy"
  user = "${aws_iam_user.velero_user[0].name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${var.dr_velero_backup_bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.dr_velero_backup_bucket}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_access_key" "velero_user_access_keys" {
  count = var.iam_create_user ? 1 : 0
  user    = "${aws_iam_user.velero_user[0].name}"
}