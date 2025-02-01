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

variable "applications" {
  description = "The applications to be deployed, e.g. radarr, sonarr; the path to their library, and their port."
  type = map(object({
    # Path to where the final media content is to be stored. 
    library = string
    # Port where the application serves by default.
    port = number
  }))
}
