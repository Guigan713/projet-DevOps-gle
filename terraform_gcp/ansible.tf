resource "null_resource" "generate_ansible_inventory" {
    triggers = {
        # Se déclenche à chaque terraform apply
        always_run = timestamp()
    }

    provisioner "local-exec" {
        command = "./generate_hosts.sh"
        working_dir = path.module
    }

    depends_on = [
        module.instances,
        module.network
    ]
}