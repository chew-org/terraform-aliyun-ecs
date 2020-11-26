# output "ssh_key_name" {
#     description = "SSH Key for instance login"
#     value = "${alicloud_key_pair.ecs-test-ssh-key.key_file}"
# }

output "user_login" {
    description = "Login name for ECS instance"
    value = "root"
}

output "public_ip" {
    description = "ECS instance public IP address"
    value = "${alicloud_instance.ecs-test-instance.public_ip}"
}