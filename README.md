# tfm-chartmuseum
Generates a custom yaml to be Helm installed with _stable/chartmuseum_

## Getting Started
Initial design is for use with a [Tectonic](https://github.com/coreos/tectonic-installer) like installation on AWS.

Example `chartmuseum.tf` file utilizing this module
```
#!terraform

module chartmuseum {
  source = "git::https://github.com/jnbnyc/tfm-chartmuseum?ref=v1.0.0"

  aws_extra_tags           = "${map("kubernetesCluster", "${var.cluster_name}",)}"
  force_destroy_s3_buckets = false
  kube2iam_enabled         = true
  prefix                   = "${var.cluster_name}"
}

# use the module output to write the yaml to it's destination
resource local_file chartmuseum_custom_values {
  content  = "\n${module.chartmuseum.values_yaml}"
  filename = "./generated/${local.workspace}/charts/chartmuseum/custom.yaml"
}

variable cluster_name {
  type = "string"
}

output chartmuseum_values_yaml {
  value = "${local_file.chartmuseum_custom_values.content}"
}
```

### TODO
- Create a cross-region replication s3 bucket for resilience
- Support other common options for custom.yaml, especially for other STORAGE providers
