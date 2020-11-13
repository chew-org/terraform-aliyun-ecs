output "ssh_key_name" {
    description = "SSH Key for instance login"
    value = "${alicloud_key_pair.ecs-test-ssh-key.key_file}"
}

output "user_login" {
    description = "Login name for ECS instance"
    value = "root"
}

output "public_ip" {
    description = "ECS instance public IP address"
    value = "${alicloud_instance.ecs-test-instance.public_ip}"
}

output "image_id" {
  value = "${data.alicloud_images.ubuntu_images.images.0.id}"
}

output "instance_type" {
  value = "${data.alicloud_instance_types.instance_types_zone_0.instance_types.0.id}"
}

output "app_rds_connection_string" {
  value = "${alicloud_db_instance.app_rds.connection_string}"
}