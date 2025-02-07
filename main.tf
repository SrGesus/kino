terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    prowlarr = {
      source = "devopsarr/prowlarr"
    }
    radarr = {
      source = "devopsarr/radarr"
    }
    sonarr = {
      source = "devopsarr/sonarr"
    }
    lidarr = {
      source = "devopsarr/lidarr"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig
}

resource "kubernetes_namespace" "kino" {
  metadata {
    name = var.namespace
  }
}

module "deployment" {
  source    = "./deployment"
  namespace = "kino"
  downloads = var.downloads
  qbittorrent_password = var.qbittorrent_password
  providers = {
    kubernetes = kubernetes
  }
  applications = {
    prowlarr = {
      library = "~/Downloads/Movies"
    }
    radarr = {
      # Path to where the final media content is to be stored. 
      library = "~/Downloads/Movies/Movies"
    }
    sonarr = {
      library = "~/Downloads/Movies/Shows"
    }
    lidarr = {
      library = "~/Downloads/Music"
    }
  }
}

resource "null_resource" "deployment" {
  depends_on = [
    kubernetes_namespace.kino,
    module.deployment
  ]
}
