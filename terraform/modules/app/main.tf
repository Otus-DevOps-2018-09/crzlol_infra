resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  network = "default"

  allow {
    protocol = "tcp"

    ports = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["reddit-app"]
}

resource "null_resource" "app" {
  triggers {
    environ = "prod"
  }

    provisioner "file" {
    source      = "../modules/deploy.sh"
    destination = "/home/appuser/deploy.sh"

    connection {
      type        = "ssh"
      user        = "appuser"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    source      = "../modules/reddit_systemd_add.sh"
    destination = "/home/appuser/reddit_systemd_add.sh"

    connection {
      type        = "ssh"
      user        = "appuser"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ./deploy.sh",
      "chmod +x ./reddit_systemd_add.sh",
      "./deploy.sh",
      "echo \"DATABASE_URL = ${var.db_internal_ip}\" > /home/appuser/reddit/database_ip",
      "sudo ./reddit_systemd_add.sh",
    ]

    connection {
      type        = "ssh"
      user        = "appuser"
      private_key = "${file(var.private_key_path)}"
    }
  }
}