
terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"  #, version = "1.33.2"
    }
    dotenv = {
      source  = "jrhouston/dotenv"  #, version = "~> 1.0"
    }
  }
}


data dotenv env_config {
  filename = ".env"
}


# Configure the Hetzner Cloud Provider
provider "hcloud" {
  # Configuration options
  token = data.dotenv.env_config.env.HCLOUD_TOKEN
}


#  Main ssh key
resource "hcloud_ssh_key" "default" {
  name       = "lainiwa key"
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "hcloud_server" "srvs" {
  name = "srv"
  image = "ubuntu-22.04"
  server_type = "cx21"
  ssh_keys = [hcloud_ssh_key.default.name]
  location = "fsn1"
  # Establishes connection to be used by all
  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    type     = "ssh"
    user     = "root"
    host     = self.ipv4_address
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
      "apt-get -qq update",
      "apt-get -yqq install docker.io docker-compose",
    ]
  }
}


resource "null_resource" "update_repo" {
  triggers = {
    always_run = "${timestamp()}"
  }
  connection {
    type     = "ssh"
    user     = "root"
    host     = hcloud_server.srvs.ipv4_address
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/lainiwa/operations || true",
      "cd ~/operations && git fetch --all && git reset --hard origin/master",
    ]
  }
  provisioner "file" {
    source      = ".env"
    destination = "/root/operations/.env"
  }
  provisioner "remote-exec" {
    inline = [
      "cd ~/operations && ./scripts/run_cloud",
    ]
  }
}


output "deployed" {
  value = hcloud_server.srvs.ipv4_address
}
