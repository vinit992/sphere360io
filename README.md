# sphere360io

Project Structure
`aws-devops-assessment/
├── main.tf
├── outputs.tf
├── deploy.sh
└── destroy.sh`

Execution & Demo Flow
1. Configure AWS Credentials:
  `aws configure`
2. Run the Automated Deployment:
  `./deploy.sh`
3. Cleanup Script:
   `./destroy.sh`

Verify in Browser: Open the printed URL (e.g., `http://<PUBLIC_IP>`). We will see the NGINX `"Hello World"` page showing Server Address, Name, and Date.
Demonstrate Requirement Compliance to Reviewer:
Auto-restart proof: Explain the `--restart always` Docker flag inside `user_data` ensuring the container restarts on process crash or reboot.
Security Group proof: Show that only ports `80` and `443` are open (SSH port 22 is closed to adhere strictly to requirement #1).
Custom VPC proof: Inspect `aws_vpc.main` (10.0.0.0/16) and aws_subnet.public in the AWS Console or via `terraform show`

1. External Connectivity & Port Testing (From Your Local Machine)
   Since the Security Group intentionally closes SSH and only allows ports 80/443, use these commands first:
   Test HTTP Response & Headers:
   # Verbose curl to inspect HTTP handshake and response
   `curl -Iv http://<PUBLIC_IP>`
   # Test with timeout to detect if traffic is blocked by Security Group / Routing
   `curl -m 5 -I http://<PUBLIC_IP>`

   Test Port Reachability:
   Linux / Macos
   `nc -zv -w 3 <PUBLIC_IP> 80`
2. Internal Container & Auto-Restart Debugging (On the EC2 Instance)
   If you log into the instance (via SSM Session Manager or temporary SSH), use these commands:
   A. Check User-Data Execution Log:
   # View the complete log of the startup script
    `sudo cat /var/log/cloud-init-output.log | tail -n 50`
   B. Check Docker Daemon:
   # Verify Docker service is active and enabled
    `sudo systemctl status docker`
  # View Docker service logs if it failed to start
    `sudo journalctl -u docker -e --no-pager`
  C. Inspect Running Container:
  # Check if container is running or restarting
  `sudo docker ps -a`
  # View container output logs
  `sudo docker logs webapp`
  # Test container locally from inside the instance
  `curl -I http://localhost:80`
  D. Live Demonstration of Auto-Restart (Great for Reviewers!):
  To prove requirement "Ensure the container automatically restarts if it crashes":
  # 1. Kill the container abruptly
    `sudo docker kill webapp`
  # 2. Check status immediately (status will show 'Restarting' or 'Up X seconds')
    `sudo docker ps`

3. Emergency: If You Need Temporary SSH Access

If the evaluator asks you to SSH into the box to show files:

Add your public key and port 22 in main.tf:
`# Temporary SSH Ingress inside aws_security_group.web_sg:
ingress {
  description = "Temporary SSH for Debugging"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # Or your specific IP: "x.x.x.x/32"
}`
Apply changes in 10 seconds:
`terraform apply -auto-approve`
Connect (if you launched with a key pair):
`ssh -i /path/to/key.pem ec2-user@<PUBLIC_IP>`
