#!terraform
output values_yaml {
  value = "${data.template_file.custom_yaml.rendered}"
}
