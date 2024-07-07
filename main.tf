# Define the required providers, specifying the Docker provider from kreuzwerker
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker" # Docker provider source
      version = "~> 3.0.1"           # Version constraint for the Docker provider
    }
  }
}

# Configure the Docker provider with the host path
provider "docker" {
  host = "" # Path to the Docker socket
}

# Create a Docker network for Jenkins containers
resource "docker_network" "private_network" {
  name            = "jenkins" # Network name
  driver          = "bridge"  # Network driver
  check_duplicate = true      # Ensure the network is not duplicated
}

# Create a Docker volume for Jenkins home directory
resource "docker_volume" "jenkins_home" {
  name = "jenkins_home" # Volume name
}

# Create a Docker volume for Jenkins Docker certificates
resource "docker_volume" "jenkins_docker_certs" {
  name = "jenkins_docker_certs" # Volume name
}

# Define a Docker container for Docker-in-Docker (dind) to enable Docker commands within Jenkins
resource "docker_container" "docker_bind" {
  name         = "docker_bind"                       # Container name
  image        = "docker:dind"                       # Use the Docker-in-Docker image
  privileged   = true                                # Run in privileged mode to access Docker daemon
  network_mode = docker_network.private_network.name # Attach to the created network
  restart      = "unless-stopped"                    # Restart policy
  env          = ["DOCKER_TLS_CERTDIR=/certs"]       # Environment variables
  ports {
    internal = 2376 # Internal port for Docker daemon
    external = 2376 # External port mapping
  }
  volumes {
    container_path = "/var/jenkins_home"             # Mount path for Jenkins home
    volume_name    = docker_volume.jenkins_home.name # Volume to mount
  }
  volumes {
    container_path = "/certs/client"                         # Mount path for Docker certs
    volume_name    = docker_volume.jenkins_docker_certs.name # Volume to mount
  }
}

# Build a Docker image for Jenkins from a Dockerfile
resource "docker_image" "jenkins_image" {
  name = "jenkins" # Image name
  build {
    context    = "."          # Build context
    dockerfile = "Dockerfile" # Dockerfile to use
  }
}

# Define a Docker container for Jenkins
resource "docker_container" "jenkins" {
  name         = "jenkins"                           # Container name
  image        = docker_image.jenkins_image.image_id # Use the built Jenkins image
  network_mode = docker_network.private_network.name # Attach to the created network
  restart      = "unless-stopped"                    # Restart policy
  env = [
    "DOCKER_HOST=tcp://docker:2376",  # Docker host for Jenkins to connect to
    "DOCKER_CERT_PATH=/certs/client", # Path to Docker certs
    "DOCKER_TLS_VERIFY=1",            # Enable TLS verification
  ]
  ports {
    internal = 8080 # Jenkins web interface port
    external = 8080 # External port mapping for web interface
  }
  ports {
    internal = 50000 # Jenkins agent port
    external = 50000 # External port mapping for agents
  }
  volumes {
    container_path = "/var/jenkins_home"             # Mount path for Jenkins home
    volume_name    = docker_volume.jenkins_home.name # Volume to mount
  }
  volumes {
    container_path = "/certs/client"                         # Mount path for Docker certs
    volume_name    = docker_volume.jenkins_docker_certs.name # Volume to mount
    read_only      = true                                    # Mount the volume as read-only
  }
  depends_on = [docker_container.docker_bind] # Ensure dind container is started first
}
