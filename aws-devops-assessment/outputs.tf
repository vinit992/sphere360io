output "public_ip" {
  description = "The public IPv4 address of the web server"
  value       = aws_instance.web.public_ip
}

output "application_url" {
  description = "Public URL to access the running container application"
  value       = "http://${aws_instance.web.public_ip}"
}
