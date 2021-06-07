#Output of private IPs
output "public_ips_subnet1" {
  description = "ec2-instances nodes public IPs"
  value       = [aws_instance.ec2-vms.*.public_ip]
}

output "private_ips" {
  description = "ec2-instances private IPs"
  value       = [aws_instance.ec2-vms.*.private_ip]
}
