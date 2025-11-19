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
  default = "eu-frankfurt-1"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key content for instance login (one-line)"
}

provider "oci" {
  region = var.region
  # auth automatically picked from OCI_* env vars
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# NEW: look up a suitable Ubuntu ARM image for A1 Flex
data "oci_core_images" "ubuntu_a1" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  # if you ever get a "no images" error, comment this line out or adjust the version
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "my_first_instance" {
  compartment_id = var.compartment_id

  display_name        = "MyTerraformA1Test"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  # CHANGED: Arm shape
  shape = "VM.Standard.A1.Flex"

shape_config {
  ocpus         = 1
  memory_in_gbs = 1
}

  source_details {
    source_type = "image"
    # CHANGED: use the image from the data source above
    source_id   = data.oci_core_images.ubuntu_a1.images[0].id
  }

  create_vnic_details {
    # same existing subnet – still fine
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
