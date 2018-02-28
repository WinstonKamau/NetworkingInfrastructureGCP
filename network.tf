resource "google_compute_network" "new-network-1" {
    name = "new-network-1"
    description = "A network meant to be used by the new instance created"
}

output "time-created" {
    value = "${google_compute_network.new-network-1.creationTimestamp}"
}


resource "google_compute_firewall" "backend-firewall" {
  name    = "backend-firewall"
  network = "${google_compute_network.new-network-1.name}"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "8000", "22", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["backend"]
}

resource "google_compute_firewall" "front-firewall" {
  name    = "front-firewall"
  network = "${google_compute_network.new-network-1.name}"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "3000", "22", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["front"]
}
