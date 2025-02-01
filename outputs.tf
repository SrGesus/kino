

# Wait for config file to be created
resource "time_sleep" "config_delay" {
  depends_on      = [kubernetes_deployment.applications, kubernetes_deployment.prowlarr]
  create_duration = "10s"
}
data "local_file" "applications_config" {
  for_each   = var.applications
  filename   = "${local.data_folder[each.key]}/config.xml"
  depends_on = [time_sleep.config_delay]
}

data "local_file" "prowlarr_config" {
  filename   = "${local.prowlarr_config}/config.xml"
  depends_on = [time_sleep.config_delay]
}


output "api_keys" {
  value = merge(
    {
      for key, value in data.local_file.applications_config : key => regex("<ApiKey>(.*)</ApiKey>", value.content).0
    },
    {
      prowlarr = regex("<ApiKey>(.*)</ApiKey>", data.local_file.prowlarr_config.content).0
    }
  )

  sensitive = false
}
