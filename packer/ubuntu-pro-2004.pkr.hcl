source "googlecompute" "ubuntu-pro-20" {
  project_id          = var.project_id
  source_image_family = "ubuntu-pro-2004-lts"
  ssh_username        = "root"
  zone                = var.zone
  # nested virtualization
  image_licenses = ["projects/vm-options/global/licenses/enable-vmx"]
}

build {
  name = "ubuntu-pro-20"
  source "googlecompute.ubuntu-pro-20" {
    image_name = "ubuntu-pro-20"
  }

  provisioner "file" {
    source      = "./scripts"
    destination = "/var/tmp/"
  }

  provisioner "shell" {
    script            = "./scripts/update_apt_packages.sh"
    expect_disconnect = true
    max_retries       = 5
  }

  provisioner "shell" {
    scripts = [
      "./scripts/install_common_software.sh",
      "./scripts/install_ops_agent.sh",
    ]
    expect_disconnect = true
  }
}
