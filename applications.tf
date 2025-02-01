## Deploy Sonarr to Kubernetes
locals {
  data_folder = {
    for key, value in var.applications : key => "${abspath(path.module)}/data/${key}"
  }
}

resource "kubernetes_deployment" "applications" {
  for_each = var.applications
  metadata {
    name      = each.key
    namespace = var.namespace
    labels = {
      "app" = "${each.key}"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "${each.key}"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "${each.key}"
        }
      }
      spec {
        container {
          name  = each.key
          image = "ghcr.io/linuxserver/${each.key}:latest"
          env {
            name  = "TZ"
            value = "Europe/Lisbon"
          }
          env {
            name  = "PUID"
            value = "1000"
          }
          env {
            name  = "PGID"
            value = "1000"
          }
          port {
            name           = "web"
            container_port = each.value.port
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          volume_mount {
            name       = "library"
            mount_path = "/library"
          }
          volume_mount {
            name       = "downloads"
            mount_path = "/downloads"
          }
        }
        volume {
          name = "data"
          host_path {
            path = local.data_folder[each.key]
            type = "DirectoryOrCreate"
          }
        }
        volume {
          name = "library"
          host_path {
            path = pathexpand(each.value.library)
            type = "DirectoryOrCreate"
          }
        }
        volume {
          name = "downloads"
          host_path {
            path = pathexpand(var.downloads)
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "applications" {
  for_each = var.applications
  metadata {
    name      = each.key
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = each.key
    }
    port {
      name        = "web"
      port        = 80
      target_port = "web"
    }
  }
  depends_on = [
    kubernetes_deployment.applications
  ]
}
