resource "google_compute_network" "main" {
    name = "main-vpc"
    ip_cidr_range = 
    auto_create_subnetworks = false
    project = var.project
}

resource "google_compute_subnetwork" "public" {
    name = "public-subnet"
    ip_cidr_range = var.public_subnet_cidr
    network = google_compute_network.main.id
    region = var.region
}

resource "google_compute_subnetwork" "private" {
  name = "private-subnet"
  ip_cidr_range = var.private_subnet_cidr
  network = google_compute_network.main.id
  region = var.region
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "main-router"
  network = google_compute_network.main.id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name     = "main-nat"
  router   = google_compute_router.router.name
  region   = var.region

  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
