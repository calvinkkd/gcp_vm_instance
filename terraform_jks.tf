provider "google" {
  project = "clean-brace-335322"
  region  = "europe-west4"
  zone    = "europe-west4-a"
}

resource "google_compute_instance" "jenkins" {
  name         = "jenkins"
  machine_type = "n1-standard-1" 
  zone         = "europe-west4-a"
  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Add a public IP address to the instance
      nat_ip = ""
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y openjdk-11-jdk
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
    sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    apt-get update
    apt-get install -y jenkins
    EOF

  metadata = {
    // Add an SSH key to the instance
    ssh-keys = "kofi:${file("~/.ssh/id_rsa.pub")}"
  }

  lifecycle {
    ignore_changes = [
      metadata_startup_script
    ]
  }
}

// Add a firewall rule to allow HTTP and HTTPS traffic
// from the outside to the Jenkins instance
resource "google_compute_firewall" "jenkins" {
  name    = "jenkins-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
}

output "jenkins_ip" {
  value = google_compute_instance.jenkins.network_interface.0.access_config.0.nat_ip
}
