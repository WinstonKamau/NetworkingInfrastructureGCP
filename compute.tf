data "google_compute_zones" "available" {}

resource "google_compute_instance" "api" {
    project = "${var.project}"
    zone = "${var.zone}"
    tags = ["backend"]
    name = "flask-api-backend"
    machine_type = "f1-micro"
    boot_disk {
        initialize_params {
            image = "ubuntu-1604-xenial-v20170328"
        }
    }
    metadata {
    databaseURI = "${var.database-uri}"    
  }

    network_interface {
        network = "${google_compute_network.new-network-1.name}"
        access_config {
            nat_ip = "${var.ip-address}"
        }
        address = "10.142.0.3"
    }

    metadata_startup_script = "${file("deploy_flask.sh")}"
}

resource "google_compute_instance" "front" {
    project = "${var.project}"
    zone = "${var.zone}"
    name = "react-front-end"
    machine_type = "f1-micro"
    tags = ["front"]
    boot_disk {
        initialize_params {
            image = "ubuntu-1604-xenial-v20170328"
        }
    }
    network_interface {
        network = "${google_compute_network.new-network-1.name}"
        access_config {
            //Ephemeral
        }
    }

    metadata {
    apiURL = "http://${var.ip-address}:8000/"   
  }

    metadata_startup_script = "${file("deploy_react.sh")}"
}

output "instance_id" {
    value = "${google_compute_instance.api.selflink}"
}