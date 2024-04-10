packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "mongodb7-ami-${legacy_isotime("2006-01-02")}"
  instance_type = "t2.medium"
  region        = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username  = "ubuntu"
  tags = {
    Name    = "mongodb7-ami-${legacy_isotime("2006-01-02")}"
    AmiType = "dev-mongodb7"
  }
}

build {
  name = "mongodb7-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    script = "${path.root}/scripts/base.sh"
  }
  provisioner "file" {
    source      = "${path.root}/scripts/install-docker.sh"
    destination = "~/shell.tmp.sh"
  }
  provisioner "shell" {
    inline = ["sudo bash ~/shell.tmp.sh"]
  }

  provisioner "ansible-local" {
    playbook_file = "${path.root}/ansible/mongodb7.yml"
    role_paths    = ["${path.root}/ansible/roles/mongodb7"]
  }
}