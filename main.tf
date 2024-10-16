provider "aws" {
  region = var.region
  access_key = "***********"
  secret_key = "******************"
}


# Allocate Elastic IP for ns1
resource "aws_eip" "ns1_eip" {

  tags = {
    Name = "ns1-eip"
  }
}

# Allocate Elastic IP for ns2
resource "aws_eip" "ns2_eip" {

  tags = {
    Name = "ns2-eip"
  }
}

# Launch EC2 Instance ns1 (Primary)
resource "aws_instance" "ns1" {
  ami                    = var.ami
  instance_type          = var.instance_type
#   subnet_id              = data.aws_subnets.default.ids[0] # Using the first default subnet
  security_groups        = ["alltraffic"]
  key_name               = var.key_name
  associate_public_ip_address = false # Elastic IP will be associated separately

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y bind9 bind9utils bind9-doc

              # Create zones directory
              mkdir -p /etc/bind/zones

              # Configure BIND9 as Master
              cat <<EOL > /etc/bind/named.conf.local
              zone "${var.domain}" {
                  type master;
                  file "/etc/bind/zones/db.${var.domain}";
                  allow-transfer { ${aws_eip.ns2_eip.public_ip}; };
              };
              EOL

              # Create zone file
              cat <<EOL > /etc/bind/zones/db.${var.domain}
              \$TTL    60
              @       IN      SOA     ${var.primary_ns}. admin.${var.domain}. (
                                    2023100901         ; Serial (YYYYMMDDXX)
                                    604800             ; Refresh
                                    86400              ; Retry
                                    2419200            ; Expire
                                    604800 )           ; Negative Cache TTL
              ;
              @       IN      NS      ${var.primary_ns}.
              @       IN      NS      ${var.secondary_ns}.
              
              ; A records for nameservers
              ns1     IN      A       ${aws_eip.ns1_eip.public_ip}
              ns2   IN      A       ${aws_eip.ns2_eip.public_ip}
              
              ; A record for the domain
              @       IN      A       ${aws_eip.ns1_eip.public_ip}
              
              ; New A record for akash
              akash   IN      A       ${aws_eip.ns1_eip.public_ip}
              EOL

              # Configure BIND9 options with logging
              cat <<EOL > /etc/bind/named.conf.options
              options {
                  directory "/var/cache/bind";

                  forwarders {
                      8.8.8.8;
                      8.8.4.4;
                  };

                  dnssec-validation auto;
                  listen-on { any; };
                  listen-on-v6 { any; };
                  allow-query { any; };
                   };
                  logging {
                      channel default_log {
                          file "/var/log/named/default.log";
                          severity info;
                          print-time yes;
                      };

                      category queries { default_log; };
                  };
              
              EOL

              # Ensure log directory exists and has correct permissions
              mkdir -p /var/log/named
              chown bind:bind /var/log/named
              chmod 750 /var/log/named

              # Restart BIND9 to apply configurations
              systemctl restart bind9
              EOF

  tags = {
    Name = "ns1"
  }
}

# Launch EC2 Instance ns2 (Secondary)
resource "aws_instance" "ns2" {
  ami                    = var.ami
  instance_type          = var.instance_type
#   subnet_id              = data.aws_subnets.default.ids[0] # Using the same subnet
  security_groups        = ["alltraffic"]
  key_name               = var.key_name
  associate_public_ip_address = false # Elastic IP will be associated separately

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y bind9 bind9utils bind9-doc

              # Configure BIND9 as Slave
              mkdir -p /var/cache/bind

              cat <<EOL > /etc/bind/named.conf.local
              zone "${var.domain}" {
                  type slave;
                  file "/var/cache/bind/db.${var.domain}";
                  masters { ${aws_eip.ns1_eip.public_ip}; };
              };
              EOL

              # Configure BIND9 options with logging
              cat <<EOL > /etc/bind/named.conf.options
              options {
                  directory "/var/cache/bind";

                  forwarders {
                      8.8.8.8;
                      8.8.4.4;
                  };

                  dnssec-validation auto;
                  listen-on { any; };
                  listen-on-v6 { any; };
                  allow-query { any; };
                  };
                  logging {
                      channel default_log {
                          file "/var/log/named/default.log";
                          severity info;
                          print-time yes;
                      };

                      category queries { default_log; };
                  };
              
              EOL

              # Ensure log directory exists and has correct permissions
              mkdir -p /var/log/named
              chown bind:bind /var/log/named
              chmod 750 /var/log/named

              # Restart BIND9 to apply configurations
              systemctl restart bind9
              EOF

  tags = {
    Name = "ns2"
  }
}

# Associate Elastic IPs to instances
resource "aws_eip_association" "ns1_association" {
  instance_id   = aws_instance.ns1.id
  allocation_id = aws_eip.ns1_eip.id
}

resource "aws_eip_association" "ns2_association" {
  instance_id   = aws_instance.ns2.id
  allocation_id = aws_eip.ns2_eip.id
}

# Outputs
output "ns1_public_ip" {
  description = "Public IP of ns1"
  value       = aws_eip.ns1_eip.public_ip
}

output "ns2_public_ip" {
  description = "Public IP of ns2"
  value       = aws_eip.ns2_eip.public_ip
}
