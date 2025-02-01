locals {
  nginx_config = "${abspath(path.module)}/data/nginx"
  nginx_html = "${abspath(path.module)}/html"
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
            read_only = true
          }
          volume_mount {
            name       = "html"
            mount_path = "/usr/share/nginx/html"
            read_only = true
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
