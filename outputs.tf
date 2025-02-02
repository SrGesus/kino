# Wait for config file to be created
resource "time_sleep" "config_delay" {
  triggers = {
    always_run = timestamp()
  }
  depends_on      = [kubernetes_deployment.applications]
  create_duration = "10s"
}

data "local_file" "applications_config" {
  for_each   = var.applications
  filename   = "${local.data_folder[each.key]}/config.xml"
  depends_on = [time_sleep.config_delay]
}

resource "local_file" "applications_nginx_confs" {
  for_each = merge(var.applications)
  filename = "${var.nginxconfigs}/routes/${each.key}.conf"
  content  = <<EOT
    location /${each.key} {
      proxy_pass http://${each.key}-web.${var.namespace};
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_redirect off;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $http_connection;
    }
  EOT
}

resource "local_file" "html_website_list" {
  filename = "html/assets/applist.json"
  content = jsonencode(
    concat(
      [
        for key, value in var.applications : key
      ],
      [
        "jellyfin",
        "qbittorrent"
      ]
    )
  )
}

output "api_keys" {
  value = merge(
    {
      for key, value in data.local_file.applications_config : key => regex("<ApiKey>(.*)</ApiKey>", value.content).0
    },
    {}
  )

  sensitive = false
}
