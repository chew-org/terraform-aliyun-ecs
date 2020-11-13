provider "alicloud" {
}

data "alicloud_zones" "cloud_zones" {}

data "alicloud_instance_types" "cores2mem4g" {
  memory_size       = 4
  cpu_core_count    = 2
  availability_zone = "${data.alicloud_zones.cloud_zones.zones.0.id}"
}

resource "alicloud_vpc" "ecs-test-vpc" {
  name       = "ecs-test-vpc"
  cidr_block = "192.168.0.0/16"
}

resource "alicloud_vswitch" "ecs-test-vswitch" {
  name              = "ecs-test-vswitch"
  vpc_id            = "${alicloud_vpc.ecs-test-vpc.id}"
  cidr_block        = "192.168.0.0/24"
  availability_zone = "${data.alicloud_zones.cloud_zones.zones.0.id}"
}

resource "alicloud_security_group" "ecs-test-hk" {
  name        = "ecs-test-hk"
  vpc_id      = "${alicloud_vpc.ecs-test-vpc.id}"
  description = "Webserver security group"
}

resource "alicloud_security_group_rule" "http-in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "80/80"
  security_group_id = "${alicloud_security_group.ecs-test-hk.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "ssh-in" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  security_group_id = "${alicloud_security_group.ecs-test-hk.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "icmp-in" {
  type              = "ingress"
  ip_protocol       = "icmp"
  policy            = "accept"
  port_range        = "-1/-1"
  security_group_id = "${alicloud_security_group.ecs-test-hk.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_key_pair" "ecs-test-ssh-key" {
  key_name = "ecs-test-ssh-key"
  key_file = "ecs-test-ssh-key.pem"
}

resource "alicloud_instance" "ecs-test-instance" {
  instance_name = "ecs-test-instance"

  instance_type        = "${data.alicloud_instance_types.cores2mem4g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.ecs-test-hk.id}"]
  vswitch_id           = "${alicloud_vswitch.ecs-test-vswitch.id}"

  user_data = "${file("install_apache.sh")}"

  key_name = "${alicloud_key_pair.ecs-test-ssh-key.key_name}"

  internet_max_bandwidth_out = 10
}

data "alicloud_images" "ubuntu_images" {
  owners = "system"
  name_regex = "ubuntu_18[a-zA-Z0-9_]+64"
  most_recent = true
}