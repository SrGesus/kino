# provider "radarr" {
#   url = module.k8s.service_ip["radarr"]
#   api_key = module.k8s.api_key["radarr"]
# }

# resource "radarr_root_folder" "movies" {
#   path = "/library"
#   depends_on = [ module.k8s ]
# }

# # resource "radarr_download_client_qbittorrent" "client" {
# #   enable = true
# #   name = "qBittorrent"
# #   host = module.k8s.qbit_host
# #   port = module.k8s.qbit_port
# #   username = "admin"
# #   password = module.k8s.qbittorrent_password
# #   movie_category = "radarr"
# #   depends_on = [ module.k8s ]
# # }


# resource "radarr_host" "radarr" {
#   depends_on = [ radarr_root_folder.movies, radarr_download_client_qbittorrent.client ]
#   launch_browser  = true
#   bind_address    = "*"
#   port            = 80
#   url_base        = "/radarr"
#   instance_name   = "Radarr"
#   application_url = ""
  
#   authentication = {
#     method   = "forms"
#     required = "enabled"
#     username = var.username
#     password = var.password
#   }
#   proxy = {
#     enabled = false
#   }
#   ssl = {
#     enabled                = false
#     certificate_validation = "enabled"
#   }
#   logging = {
#     log_level = "info"
#     analytics_enabled = true
#   }
#   backup = {
#     folder    = "Backups"
#     interval = 7
#     retention = 28
#   }
#   update = {
#     mechanism = "docker"
#     branch    = "main"
#   }
# }

# # Restart Radarr when settings change because the provider doesn't seem to do it automatically
# resource "null_resource" "radarr_restart" {
#   provisioner "local-exec" {
#     command = "curl -X POST ${module.k8s.service_ip["radarr"]}/api/v3/system/restart?apikey=${module.k8s.api_key["radarr"]}"
#   }
#   depends_on = [ radarr_host.radarr ]
# }

