variable "namespace" {
  description = "The name of the namespace for the services."
  type        = string
  default     = "kino"
}

variable "kubeconfig" {
  description = "The path to the kubernetes configuration"
  type        = string
  default     = "~/.kube/config"
}

variable "downloads" {
  description = "The absolute path where Downloaded content is to be stored."
  type        = string
}

variable "username" {
  description = "Servarr applications username."
  default = "abc"
}

variable "password" {
  description = "Servarr applications password."
  default = "1"
}

variable "qbittorrent_password" {
  type = string
}