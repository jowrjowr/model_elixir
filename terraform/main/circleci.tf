resource "aws_iam_user" "circleci_deployment" {
  name = "circleci-model_elixir-${var.environment}"
  path = "/circleci/"

  tags = {
    Name = "circleci"
  }
}

data "aws_iam_policy_document" "circleci_deployment" {

  statement {
    sid    = "S3List"
    effect = "Allow"
    actions = [
      "s3:List*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "ControlNixChannels"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::company-model_elixir-*-nix-channel/*",
      "arn:aws:s3:::company-model_elixir-*-nix-binary-cache/*",
      "arn:aws:s3:::company-model_elixir-*-static/*"
    ]
  }

  statement {
    sid    = "EC2Reading"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "circleci_deployment" {
  name        = "model_elixir-CircleCI-Deployment-${var.environment}"
  description = "Permissions to deploy from CircleCI"
  policy      = data.aws_iam_policy_document.circleci_deployment.json
}

resource "aws_iam_user_policy_attachment" "circleci_deployment" {
  user       = aws_iam_user.circleci_deployment.name
  policy_arn = aws_iam_policy.circleci_deployment.arn
}
