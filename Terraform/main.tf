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
  type        = string
  description = "Public SSH key content for instance login (one-line)"
}

provider "oci" {
  region = var.region
  # Auth is picked up from OCI_* env vars set in GitHub Actions
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Look up a recent Ubuntu image for the micro shape
data "oci_core_images" "ubuntu_micro" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.E2.1.Micro"
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "my_first_instance" {
  compartment_id = var.compartment_id

  display_name        = "MyTerraformMicro"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  # Back to AMD micro
  shape = "VM.Standard.E2.1.Micro"

  # (Optional) You can omit this block for fixed shapes, but it's harmless:
  shape_config {
    ocpus         = 1
    memory_in_gbs = 1
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_micro.images[0].id
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
