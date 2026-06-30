provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "nextwork-prod-rahul" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  tags = {
    Env = "production"
  }
}

resource "aws_instance" "nextwork-dev-rahul" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  tags = {
    Env = "development"
  }
}

resource "aws_iam_policy" "intern_ec2_access" {
  name        = "NextworkDevEnvironmentPolicy"
  description = "Allow management of the development EC2 instance only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances",
          #   "ec2:TerminateInstances",
        ]
        Effect   = "Allow",
        Resource = "*",
        Condition = {
          "StringEquals" = {
            "ec2:ResourceTag/Env" = "development"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny",
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group" "interns" {
  name = "interns"
}

resource "aws_iam_group_policy_attachment" "interns_policy_attachment" {
  group      = aws_iam_group.interns.name
  policy_arn = aws_iam_policy.intern_ec2_access.arn
}




