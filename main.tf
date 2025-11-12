provider "oci" {
  # Credentials will be set by environment variables
}

resource "oci_core_instance" "compute_node" {
  compartment_id      = var.compartment_id
  availability_domain = var.ad
  shape               = "VM.Standard.E2.1.Micro" # or your preferred shape

  source_details {
    source_id   = var.image_id # An Oracle Linux or Ubuntu image
    source_type = "image"
  }

  create_vnic_details {
    subnet_id = var.subnet_id # Use your *existing* subnet
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }
}