source "googlecompute" "ubuntu-pro-18" {
  project_id          = var.project_id
  source_image_family = "ubuntu-pro-1804-lts"
  ssh_username        = "root"
  zone                = var.zone
  # nested virtualization
  image_licenses = ["projects/vm-options/global/licenses/enable-vmx"]
}

build {
  name = "ubuntu-pro-18"
  source "googlecompute.ubuntu-pro-18" {
    image_name = "ubuntu-pro-18"
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
    max_retries       = 2
  }
}
