# Jenkins with Docker-in-Docker (DinD) Setup

This project provides a Terraform configuration for setting up Jenkins with Docker-in-Docker (DinD) capabilities. It allows Jenkins to build and manage Docker containers within its own Docker container.

## Features

- **Docker-in-Docker**: Enables Jenkins to run Docker commands, allowing for the building, running, and managing of Docker containers directly from Jenkins pipelines.
- **Private Networking**: Utilizes a Docker bridge network for secure communication between the Jenkins container and the Docker-in-Docker container.
- **Persistent Storage**: Configures Docker volumes for Jenkins home and Docker certificates to ensure data persistence across container restarts.

## Prerequisites

- Docker installed on your host machine.
- Terraform installed on your host machine.

## Usage

1. Add the docker deamon socket to the main.tf file
   Add the path to the Docker daemon socket to the `main.tf` file. The path should be the same as the one used by the Docker daemon on your host machine.

   ```hcl
   provider "docker" {
      host = "unix:///.../docker.sock"
   }
   ```

2. Initialize Terraform within the repo directory.
   Initialize Terraform to download the required providers.

   ```bash
    terraform init
   ```

3. Apply Terraform Configuration
   Apply the Terraform configuration to create the Jenkins and Docker-in-Docker containers.

   ```bash
    terraform apply
   ```

   Confirm the action by typing `yes` when prompted.

4. Access Jenkins
   Once the containers are up and running, access Jenkins by navigating to http://localhost:8080 in your web browser. You can log in with the credentials provided in the Jenkins logs.
