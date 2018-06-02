module "provider" {
  source          = "./provider/digitalocean"

  token           = "${var.digitalocean_token}"
  ssh_keys        = "${var.digitalocean_ssh_keys}"
  size            = "${var.digitalocean_size}"
  hosts           = "${var.hosts}"
  hostname_format = "${var.hostname_format}"
  region          = "${var.digitalocean_region}"
}

module "dns" {
  source     = "./dns/aws"

  count      = "${var.hosts}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
  domain     = "${var.domain}"
  public_ips = "${module.provider.public_ips}"
  hostnames  = "${module.provider.hostnames}"
}

module "swap" {
  source      = "./service/swap"

  count       = "${var.hosts}"
  connections = "${module.provider.public_ips}"
}

module "wireguard" {
  source       = "./security/wireguard"

  count        = "${var.hosts}"
  connections  = "${module.provider.public_ips}"
  private_ips  = "${module.provider.private_ips}"
  hostnames    = "${module.provider.hostnames}"
  overlay_cidr = "${module.kubernetes.overlay_cidr}"
}

module "firewall" {
  source               = "./security/ufw"

  count                = "${var.hosts}"
  connections          = "${module.provider.public_ips}"
  private_interface    = "${module.provider.private_network_interface}"
  vpn_interface        = "${module.wireguard.vpn_interface}"
  vpn_port             = "${module.wireguard.vpn_port}"
  kubernetes_interface = "${module.kubernetes.overlay_interface}"
}

module "etcd" {
  source      = "./service/etcd"

  count       = "${var.hosts}"
  connections = "${module.provider.public_ips}"
  hostnames   = "${module.provider.hostnames}"
  vpn_unit    = "${module.wireguard.vpn_unit}"
  vpn_ips     = "${module.wireguard.vpn_ips}"
}

module "kubernetes" {
  source                     = "./service/kubernetes"

  count                      = "${var.hosts}"
  connections                = "${module.provider.public_ips}"
  cluster_name               = "${var.domain}"
  vpn_interface              = "${module.wireguard.vpn_interface}"
  vpn_ips                    = "${module.wireguard.vpn_ips}"
  etcd_endpoints             = "${module.etcd.endpoints}"
  ssh_authorized_keys_github = "${var.ssh_authorized_keys_github}"
}

output "kube_overlay_cidr" {
  value = "${module.kubernetes.overlay_cidr}"
}
output "kube_overlay_interface" {
  value = "${module.kubernetes.overlay_interface}"
}

output "master_ip" {
  value = "${module.provider.public_ips[0]}"
}

output "master_hostname" {
  value = "${module.provider.hostnames[0]}"
}

output "all_ips" {
  value = "${module.provider.public_ips}"
}

output "all_hostnames" {
  value = "${module.provider.hostnames}"
}


## Alternative hosting and DNS providers

/*
module "provider" {
  source = "./provider/scaleway"
  organization    = "${var.scaleway_organization}"
  token           = "${var.scaleway_token}"
  hosts           = "${var.hosts}"
  hostname_format = "${var.hostname_format}"
  region          = "${var.scaleway_region}"
}

module "provider" {
  source = "./provider/hcloud"

  hosts           = "${var.hosts}"
  token           = "${var.hcloud_token}"
  type            = "${var.hcloud_type}"
  ssh_keys        = "${var.hcloud_ssh_keys}"
  location        = "${var.hcloud_location}"
  hostname_format = "${var.hostname_format}"
}

module "dns" {
  source = "./dns/google"

  count        = "${var.hosts}"
  project      = "${var.google_project}"
  region       = "${var.google_region}"
  creds_file   = "${var.google_credentials_file}"
  managed_zone = "${var.google_managed_zone}"
  domain       = "${var.domain}"
  public_ips   = "${module.provider.public_ips}"
  hostnames    = "${module.provider.hostnames}"
}
*/


/*
module "dns" {
  source = "./dns/cloudflare"

  count      = "${var.hosts}"
  email      = "${var.cloudflare_email}"
  token      = "${var.cloudflare_token}"
  domain     = "${var.domain}"
  public_ips = "${module.provider.public_ips}"
  hostnames  = "${module.provider.hostnames}"
}
*/
