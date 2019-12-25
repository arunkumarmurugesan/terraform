data "aws_kms_alias" "rds_key" { 
    name = "alias/aws/rds" 
}
data "aws_kms_alias" "es_key" { 
    name = "alias/aws/es" 
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "ntnx_app01" {
  tags = "${var.tags}"
  description   = "KMS key for app01"
  is_enabled    = "true"   
  enable_key_rotation = "true"
  policy = <<EOF
{
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                     "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/app01_app_user",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/app02_app_user"
                ]
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/app01_app_user",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/app02_app_user"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/app01_app_user",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/app02_app_user"
                ]
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}
EOF  
#policy        = "${file("${path.module}/kms_policy_dup.json")}"
  #tags = {
  #Environment = "${var.generictag}"
  #} 
}

resource "aws_kms_alias" "ntnx_app01_alias" {
  name          = "alias/${var.projectname}-ntnx-app01"
  target_key_id = "${aws_kms_key.ntnx_app01.key_id}"
}
