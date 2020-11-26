provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.access_key_secret}"
  region     = "${var.region}"
  version    = "~> 1.0"
}
#comment
data "alicloud_zones" "cloud_zones" {}

data "alicloud_instance_types" "cores2mem4g" {
  memory_size       = 8
  cpu_core_count    = 4
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

# resource "alicloud_security_group_rule" "http-in" {
#   type              = "ingress"
#   ip_protocol       = "tcp"
#   policy            = "accept"
#   port_range        = "80/80"
#   security_group_id = "${alicloud_security_group.ecs-test-hk.id}"
#   cidr_ip           = "0.0.0.0/0"
# }

# resource "alicloud_security_group_rule" "ssh-in" {
#   type              = "ingress"
#   ip_protocol       = "tcp"
#   policy            = "accept"
#   port_range        = "22/22"
#   security_group_id = "${alicloud_security_group.ecs-test-hk.id}"
#   cidr_ip           = "0.0.0.0/0"
# }

# resource "alicloud_security_group_rule" "icmp-in" {
#   type              = "ingress"
#   ip_protocol       = "icmp"
#   policy            = "accept"
#   port_range        = "-1/-1"
#   security_group_id = "${alicloud_security_group.ecs-test-hk.id}"
#   cidr_ip           = "0.0.0.0/0"
# }

# resource "alicloud_key_pair" "ecs-test-ssh-key" {
#   key_name = "ecs-test-ssh-key"
#   key_file = "ecs-test-ssh-key.pem"
# }

resource "alicloud_instance" "ecs-test-instance" {
  instance_name = "ecs-test-instance"

  image_id = "${var.test_image_id}"

  instance_type        = "${data.alicloud_instance_types.cores2mem4g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.ecs-test-hk.id}"]
  vswitch_id           = "${alicloud_vswitch.ecs-test-vswitch.id}"

  user_data = "${file("install_apache.sh")}"

  #key_name = "${alicloud_key_pair.ecs-test-ssh-key.key_name}"

  internet_max_bandwidth_out = 10
}

# provider "aws" {
#     region      = "us-east-2"
#     access_key  = "AKIAIHB632OTIW4PAKGA"
#     secret_key  = "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"
# }

# terraform {
#   backend "s3" {
#     encrypt = true
#     bucket = "tf-s3-bucket-rz"
#     region = "us-east-2"
#     dynamodb_table = "tfstate-lock-dynamo-bucket-rz"
#     key = "terraform-aliyun-ecs/terraform.tfstate"
#   }
# }