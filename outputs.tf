
output "api_keys" {
  # value = length(data.local_file.sonarr_config) > 0 ? regex("<ApiKey>(.*)</ApiKey>", data.local_file.sonarr_config.content).0 : "none"
  value = {
    for key, value in data.local_file.config : key => regex("<ApiKey>(.*)</ApiKey>", value.content).0
  }
  sensitive = false
}
