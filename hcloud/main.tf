# Local variables
locals {
  required_tags = {
    project_name = var.project_name,
    environment = var.environment,
  }

  tags = merge(var.resource_tag, local.required_tags)

  name_prefix = "${var.project_name}-${var.environment}"
}


# Configure the HCloud Provider
provider "hcloud" {
  token = var.hcloud_token 
}

# Create HCloud Network Resource
resource "hcloud_network" "vnet" {
  name     = "vnet-1"
  ip_range = var.vnet_cidr_block
  labels = local.tags
}

# Private Subnet Resource
resource "hcloud_network_subnet" "priv-subnet" {
  network_id   = hcloud_network.vnet.id
  type         = "cloud"
  network_zone = var.hcloud_region
  ip_range     = var.private_subnet_cidr_blocks[0]
}

# Public Subnet Resource
resource "hcloud_network_subnet" "pub-subnet" {
  network_id   = hcloud_network.vnet.id
  type         = "cloud"
  network_zone = var.hcloud_region
  ip_range     = var.public_subnet_cidr_blocks[0]
}

# SSH Key Resource
resource "hcloud_ssh_key" "tf_ssh_key" {
  name       = "tf-ssh-key"
  public_key = var.tf_ssh_key
}

# Primary IP Resource
resource "hcloud_primary_ip" "hcloud_ip_1" {
  name          = "tf_primary_ip"
  datacenter    = "fsn1-dc14"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
  labels = local.tags
}

# Firewall resource
resource "hcloud_firewall" "firewall" {
  name = "tf-crys_firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "86.4.161.126"
    ]
  }

  labels = local.tags

}

resource "hcloud_firewall" "firewall_priv" {
  name = "tf-crys_firewall_priv"

  # rule {
  #   direction = "in"
  #   protocol  = "tcp"
  #   port      = "80"
  #   source_ips = [
  #     "0.0.0.0/0",
  #     "::/0"
  #   ]
  # }
  
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "10.0.1.1"
    ]
  }

  labels = local.tags

}

# Create Server Resource
resource "hcloud_server" "crystal_server_1" {
  name        = "crystal-server-1"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  location  = "fsn1"
  ssh_keys = [hcloud_ssh_key.tf_ssh_key.id]
  firewall_ids = [hcloud_firewall.firewall.id]

  
  # Link a managed ipv4 but autogenerate ipv6
  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.hcloud_ip_1.id
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.vnet.id
    # ip         = "10.0.1.5"
    # alias_ips  = [
    #   "10.0.1.6",
    #   "10.0.1.7"
    # ]
  }

  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    hcloud_ssh_key.tf_ssh_key,
    hcloud_primary_ip.hcloud_ip_1,
    hcloud_network_subnet.pub-subnet
  ]
}


# Create Server Resource 2
# Allow SSH accessible from Server 1 only
# Disable public access
resource "hcloud_server" "crystal_server_2" {
  name        = "crystal-server-2"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  location  = "fsn1"
  ssh_keys = [hcloud_ssh_key.tf_ssh_key.id]
  firewall_ids = [hcloud_firewall.firewall_priv.id]

  
  # Link a managed ipv4 but autogenerate ipv6
  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.vnet.id
    # ip         = "10.0.1.5"
    # alias_ips  = [
    #   "10.0.1.6",
    #   "10.0.1.7"
    # ]
  }

  # **Note**: the depends_on is important when directly attaching the
  # server to a network. Otherwise Terraform will attempt to create
  # server and sub-network in parallel. This may result in the server
  # creation failing randomly.
  depends_on = [
    hcloud_ssh_key.tf_ssh_key,
    # hcloud_primary_ip.hcloud_ip_1,
    hcloud_network_subnet.priv-subnet
  ]
}