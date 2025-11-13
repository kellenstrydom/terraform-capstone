terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  region              = "af-johannesburg-1"
  auth                = "SecurityToken"
  config_file_profile = "learn-terraform"
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaaxz3ggtyzeg44biz3zq2nda74h3dl2lwfw4izxso4psnqvn3kgraa"
}

resource "oci_core_instance" "my_first_instance" {
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaaxz3ggtyzeg44biz3zq2nda74h3dl2lwfw4izxso4psnqvn3kgraa"

  display_name        = "MyTerraformInstance"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  # This is an always-free eligible shape
  shape = "VM.Standard.E2.1.Micro"
  shape_config {
    ocpus         = 1
    memory_in_gbs = 1
  }

  # This block defines the OS image
  source_details {
    source_type = "image"
    # Paste the Image OCID you copied in Step 2
    source_id = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaa2phcuwxg7bzo465kpkygb4xi73ccgfrqkviyz3jq6jtbnu3bqxda"
  }

  # This block defines the network
  create_vnic_details {
    subnet_id        = "ocid1.subnet.oc1.af-johannesburg-1.aaaaaaaaedwkg5lzt25pydgityufwigu7vguptfaytnqx3pm5yfd5ip2ntra"
    assign_public_ip = true # Get a public IP so you can SSH
  }

  # This block adds your SSH key for login
  metadata = {
    ssh_authorized_keys = file("/mnt/c/Users/kelle/.ssh/id_ed25519.pub")
  }
}

output "instance_public_ip" {
  description = "The public IP address of the instance"
  value       = oci_core_instance.my_first_instance.public_ip
}