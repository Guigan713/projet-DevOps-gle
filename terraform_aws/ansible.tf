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
        aws_instance.frontend,
        aws_instance.reverse_proxy,
        aws_instance.backend,
        aws_instance.database,
        aws_instance.monitoring
    ]
}