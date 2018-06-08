#!terraform

locals {
  aws_s3_region = "${aws_s3_bucket.chartmuseum.region}"
  name          = "${var.prefix != "" ? format("%s-", replace(var.prefix, "_", "-")) : ""}chartmuseum"
}

data template_file kube2iam {
  template = <<EOF
replica:
  annotations:
    iam.amazonaws.com/role: $${aws_s3_iamrole}
EOF

  vars {
    aws_s3_iamrole = "${aws_iam_role_policy.chartmuseum.name}"
  }
}

data template_file access_keys {
  template = <<EOF
secret:
    AWS_ACCESS_KEY_ID: $${aws_id} ## aws access key id value
    AWS_SECRET_ACCESS_KEY: $${aws_secret} ## aws access key secret value
EOF

  vars {
    aws_id     = "${var.aws_access_key_id}"
    aws_secret = "${var.aws_secret_access_key}"
  }
}

data template_file iam_role_policy {
  template = "${file("${path.module}/resources/iam_role_policy.json")}"

  vars = {
    aws_s3_bucket = "${local.name}"
  }
}

data template_file custom_yaml {
  template = "${file("${path.module}/resources/custom.yaml")}"

  vars = {
    aws_s3_bucket = "${local.name}"
    aws_s3_prefix = "${var.aws_s3_prefix}"
    aws_s3_region = "${local.aws_s3_region}"
    aws_access    = "${var.kube2iam_enabled ? data.template_file.kube2iam.rendered : data.template_file.access_keys.rendered}"
  }
}

resource aws_iam_role chartmuseum {
  name = "${local.name}-role"
  path = "/"

  assume_role_policy = "${file("${path.module}/resources/assume_role_policy.json")}"
}

resource aws_iam_role_policy chartmuseum {
  name = "${local.name}-policy"
  role = "${aws_iam_role.chartmuseum.id}"

  policy = "${data.template_file.iam_role_policy.rendered}"
}

resource aws_s3_bucket chartmuseum {
  bucket = "${local.name}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = "${
    merge(map("Name", "${local.name}",), var.aws_extra_tags)
  }"

  force_destroy = "${var.force_destroy_s3_buckets}"
}
