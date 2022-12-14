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
	# dont pass passwords like this, this is only a demo
	#
	env = ["MYSQL_ROOT_PASSWORD=${var.db_pass}"]
	networks_advanced {
		name = docker_network.app-net.id
	}
}

resource "docker_container" "con-web" {
	name = "bgapp"
	image = docker_image.img-web.latest
	env = ["MYSQL_ROOT_PASSWORD=${var.db_pass}"]
	networks_advanced {
		name = docker_network.app-net.id
	}
	ports {
		internal = 80
		external = 8080
	}
	volumes {
		# this is where you mount your application
		# for this example https://github.com/shekeriev/bgapp was ued
		#
		host_path = "${path.cwd}/bgapp/web"
		container_path = "/var/www/html"
	}
}