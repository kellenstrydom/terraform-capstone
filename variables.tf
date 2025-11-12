variable "compartment_id" {}
variable "ad" { default = "kMBg:AF-JOHANNESBURG-1-AD-1" } # Change to your AD
variable "image_id" { default = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaaeyp3grs25hgw6nds4jbzc4megopbcho3oawrhmyasayp4sqrxt2a" } # Change this
variable "subnet_id" {}
variable "ssh_public_key_path" { default = "~/.ssh/id_rsa.pub" }