# Path to your kube config
kubeconfig = "~/.kube/config"

# The path where Downloaded content is to be stored.
downloads = "~/Downloads"

applications = {
  radarr = {
    # Path to where the final media content is to be stored. 
    library = "~/Downloads/Movies/Movies"
    # Port where the application serves by default.
    port = 7878
  }
}
