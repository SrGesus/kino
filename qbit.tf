resource "kubernetes_deployment" "qbittorrent" {
  metadata {
    name      = "qbittorrent"
    namespace = var.namespace
    labels = {
      "app" = "qbittorrent"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "qbittorrent"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "qbittorrent"
        }
      }
      spec {
        container {
          name = "qbittorrent"
          # image = "ghcr.io/linuxserver/qbittorrent:amd64-4.6.0-r0-ls293"
          image = "ghcr.io/linuxserver/qbittorrent:4.6.0"
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
          env {
            name  = "WEBUI_PORT"
            value = "80"
          }
          env {
            name  = "TORRENTING_PORT"
            value = "6881"
          }
          port {
            name           = "web"
            container_port = 80
          }
          port {
            container_port = 6881
            protocol       = "UDP"
          }
          port {
            container_port = 6881
            protocol       = "TCP"
          }
          volume_mount {
            name       = "downloads"
            mount_path = "/downloads"
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

resource "kubernetes_service" "qbittorrent_web" {
  metadata {
    name      = "qbittorrent-web"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "qbittorrent"
    }
    port {
      name        = "web"
      port        = 80
      target_port = "web"
    }
  }
  depends_on = [
    kubernetes_deployment.qbittorrent
  ]
}

resource "kubernetes_service" "qbittorrent_torrenting" {
  metadata {
    name      = "qbittorrent-torrenting"
    namespace = var.namespace
  }
  spec {
    type = "NodePort"
    selector = {
      "app" = "qbittorrent"
    }
    port {
      name        = "tcp"
      port        = 6881
      target_port = 6881
      protocol    = "TCP"
    }
    port {
      name        = "udp"
      port        = 6881
      target_port = 6881
      protocol    = "UDP"
    }
  }
  depends_on = [
    kubernetes_deployment.qbittorrent
  ]
}
