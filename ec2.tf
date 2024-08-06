# Define the EC2 Instance
resource "aws_instance" "my-website" {
  ami                    = "ami-04a81a99f5ec58529"
  instance_type          = "t2.micro"
  key_name               = "name-of-your-ssh-key"
  availability_zone      = "us-east-1a"
  associate_public_ip_address = true
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  user_data = <<-EOF
    #!/bin/bash

    # Redirect stderr to a log file
    exec 2>/var/log/user_data_error.log

    # Update package lists and install Nginx
    sudo apt-get update -y
    sudo apt-get install -y nginx

    # Start and enable Nginx
    echo "Starting and enabling Nginx..."
    sudo systemctl start nginx
    sudo systemctl enable nginx

    # Check Nginx status
    echo "Checking Nginx status..."
    sudo systemctl status nginx

    # Create directory for website content
    sudo mkdir -p /var/www/weuweuweu.xyz/html
    sudo chown -R $USER:$USER /var/www/weuweuweu.xyz/html/
    sudo chmod -R 755 /var/www/weuweuweu.xyz/

    # Create the index.html file
    sudo bash -c 'cat << "EOL" > /var/www/weuweuweu.xyz/html/index.html
    <html>
        <head>
            <title>Welcome to weuweuweu.xyz!</title>
        </head>
        <body>
            <h1>Success! The weuweuweu.xyz server is still under construction!</h1>
        </body>
    </html>
    EOL'

    # Create the Nginx configuration file
    sudo bash -c 'cat << "EOL" > /etc/nginx/sites-available/weuweuweu.xyz
    server {
        listen 80;

        root /var/www/weuweuweu.xyz/html;
        index index.html;

        server_name weuweuweu.xyz www.weuweuweu.xyz;

        location / {
            try_files $uri $uri/ =404;
        }
    }
    EOL'

    # Enable the new site and reload Nginx
    sudo ln -s /etc/nginx/sites-available/weuweuweu.xyz /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo nginx -s reload

    # Install and configure certbot
    sudo snap install core
    sudo snap refresh core
    sudo apt-get remove -y certbot
    sudo snap install --classic certbot
    sudo certbot --version

    # Print log file path
    echo "User data script completed. Check /var/log/user_data_error.log for any errors."
  EOF

  tags = {
    Name = "my-website"
  }
}
