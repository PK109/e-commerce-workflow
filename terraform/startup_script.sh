#!/bin/bash
  set -x
  sudo apt-get update
  sudo apt-get -y install ca-certificates curl git python3-pip
  sudo install -m 0755 -d /etc/apt/keyrings
  git clone ${var.project_repo_url} /home/${var.vm_user}/e-commerce_project
  # Add Docker's official GPG key:
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu focal stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo groupadd docker
  sudo usermod -aG docker ${var.vm_user}
  newgrp docker
  echo 'alias "docker_up"="docker compose --env-file=/home/${var.vm_user}/e-commerce_project/.env -f /home/${var.vm_user}/e-commerce_project/kestra/docker-compose.yml up -d"' >> /home/${var.vm_user}/.bashrc
  echo 'alias "docker_down"="docker compose --env-file=/home/${var.vm_user}/e-commerce_project/.env -f /home/${var.vm_user}/e-commerce_project/kestra/docker-compose.yml down"' >> /home/${var.vm_user}/.bashrc
  # Preparing .env file
  cd /home/${var.vm_user}/e-commerce_project
  cp sample.env .env
  # Installing Terraform
  cd /home/${var.vm_user}/e-commerce_project/terraform/
  chmod +x ./tf_install.sh
  ./tf_install.sh
    # Installing Java
  cd /home/${var.vm_user}/e-commerce_project/spark/
  chmod +x ./java_install.sh
  ./java_install.sh
  pip install pyspark jupyter 
  cd /home/${var.vm_user}/
  sudo chown -R  przemek:przemek ./e-commerce_project/
  set +x