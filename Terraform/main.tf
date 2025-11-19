terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 4.0"
    }
  }
}

variable "compartment_id" {
  type = string
}

variable "region" {
  type    = string
  default = "af-johannesburg-1"
}

variable "ssh_public_key" {
  type = string
  description = "Public SSH key content for instance login (one-line)"
}

provider "oci" {
  region = var.region
  # auth automatically picked from OCI_* env vars or OCI_KEY_FILE written by the workflow
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_core_instance" "my_first_instance" {
  compartment_id = var.compartment_id

  display_name        = "MyTerraformInstance"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  shape = "VM.Standard.E2.1.Micro"
  shape_config {
    ocpus         = 1
    memory_in_gbs = 1
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaa2phcuwxg7bzo465kpkygb4xi73ccgfrqkviyz3jq6jtbnu3bqxda"
  }

  create_vnic_details {
    subnet_id        = "ocid1.subnet.oc1.af-johannesburg-1.aaaaaaaaedwkg5lzt25pydgityufwigu7vguptfaytnqx3pm5yfd5ip2ntra"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

output "instance_public_ip" {
  description = "The public IP address of the instance"
  value       = oci_core_instance.my_first_instance.public_ip
}