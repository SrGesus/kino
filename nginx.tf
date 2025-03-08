locals {
  nginx_html   = "${abspath(path.module)}/html"
  nginx_config = "${abspath(path.module)}/nginx"
  media_routes = "${abspath(path.module)}/nginx"
}

data "local_file" "media_routes" {
  filename = "${abspath(path.module)}/terraform-media-stack/routes.json"
}

data "local_file" "extra_routes" {
  filename = "${abspath(path.module)}/extra_routes.json"
}

resource "local_file" "applications_nginx_routes" {
  for_each = merge(jsondecode(data.local_file.media_routes.content), jsondecode(data.local_file.extra_routes.content))
  filename = "${local.nginx_config}/routes/${each.key}.conf"
  content  = <<-EOT
    %{if each.value.stripprefix == true}location /${each.key} {
      proxy_pass http://${each.key}-web.${var.namespace};
    %{else}location /${each.key}/ {
      proxy_pass http://${each.key}-web.${var.namespace}/;
      proxy_request_buffering off;
      client_max_body_size 0;
      chunked_transfer_encoding on;
      proxy_read_timeout 36000s;
      proxy_send_timeout 36000s;
    %{endif}  proxy_set_header Host $host;
      sub_filter
      '</head>'
      '<link rel="stylesheet" type="text/css" href="/assets/subfilter.css"></head>';
      sub_filter_once on;
      proxy_set_header Accept-Encoding "";
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_redirect off;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $http_connection;
    }
  EOT
}

resource "local_file" "html_website_list" {
  filename = "html/assets/applist.json"
  content = jsonencode(
    [
      for key, value in merge(jsondecode(data.local_file.media_routes.content), jsondecode(data.local_file.extra_routes.content)) : key
    ]
  )
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "nginx"
    }
    port {
      name        = "web"
      port        = 80
      target_port = "web"
    }
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx"
          port {
            name           = "web"
            container_port = 80
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/nginx/conf.d"
            read_only  = true
          }
          volume_mount {
            name       = "html"
            mount_path = "/usr/share/nginx/html"
            read_only  = true
          }
        }
        volume {
          name = "config"
          host_path {
            path = local.nginx_config
            type = "DirectoryOrCreate"
          }
        }
        volume {
          name = "html"
          host_path {
            path = local.nginx_html
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}
