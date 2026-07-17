output "server_ips" {
  description = "Public IPs of all servers."

  value = {
    for k, v in module.servers :
    k => v.public_ip
  }
}
