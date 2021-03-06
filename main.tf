terraform {
  required_version = ">= 0.13.5"
  backend "s3" {
    endpoint = "nyc3.digitaloceanspaces.com"
    region = "us-east-1" # Not actually used because state is in DO spaces, but required to pass tf init
    key = "dsm-cluster.tfstate"
    bucket = "dsm-space"

    # Skip these checks, we aren't using AWS
    skip_requesting_account_id = true
    skip_credentials_validation = true
    skip_get_ec2_platforms = true
    skip_metadata_api_check = true
  }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = ">= 2.6"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.0.3"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.2.0"
    }
  }
}

provider "digitalocean" {
  token = var.DO_TOKEN
}

resource "digitalocean_kubernetes_cluster" "kubernetes-cluster" {
  name = "${var.project_name}-cluster"
  region = var.do_region
  version = "1.21.9-do.0"

  node_pool {
    name = "${var.project_name}-pool"
    size = "s-1vcpu-2gb"
    node_count = 1
    auto_scale = true
    min_nodes = 1
    max_nodes = 2
    labels = {
      app = var.project_name
    }
  }
}


provider "helm" {
  kubernetes {
    host = digitalocean_kubernetes_cluster.kubernetes-cluster.endpoint

    token = digitalocean_kubernetes_cluster.kubernetes-cluster.kube_config[0].token
    client_certificate     = base64decode(digitalocean_kubernetes_cluster.kubernetes-cluster.kube_config[0].client_certificate)
    client_key             = base64decode(digitalocean_kubernetes_cluster.kubernetes-cluster.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.kubernetes-cluster.kube_config[0].cluster_ca_certificate)
  }
}

// Creates a DO LoadBalancer that can be targeted by DNS, and redirects ingress traffic
resource "helm_release" "ingress_nginx" {
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  name = "${var.project_name}-ingress-nginx"
  namespace = var.project_name
  create_namespace = true
}


