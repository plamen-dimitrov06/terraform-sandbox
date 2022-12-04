terraform {
	required_providers {
		docker = {
			source  = "kreuzwerker/docker"
		}
	}
}

resource "docker_network" "app-net" {
	name = "app-net"
	driver = "bridge"
}

resource "docker_image" "img-db" {
	name = "shekeriev/bgapp-db:latest"
}

resource "docker_image" "img-web" {
	name = "shekeriev/bgapp-web:latest"
}

resource "docker_container" "con-db" {
	name = "db"
	image = docker_image.img-db.latest
	env = ["MYSQL_ROOT_PASSWORD=Password1"]
	networks_advanced {
		name = docker_network.app-net.id
	}
}

resource "docker_container" "con-web" {
	name = "bgapp"
	image = docker_image.img-web.latest
	networks_advanced {
		name = docker_network.app-net.id
	}
	ports {
		internal = 80
		external = 8080
	}
	volumes {
		host_path = "${path.cwd}/bgapp/web"
		container_path = "/var/www/html"
	}
}