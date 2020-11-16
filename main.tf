#Terraform main config file
        #Defining access keys and region
provider "aws" {
        region = "${var.region}"
        access_key = "${var.access_key}"
        secret_key = "${var.secret_key}"
}

        #Selecting default VPC. In the next block we will attach this VPC to the security groups.
data "aws_vpc" "selected" {
        filter {
                name    = "tag:Name"
                values  = ["default"]
        }
}

        #Create new aws security group for database instance. Only MySQL and SSH ports is open for outside.
resource "aws_security_group" "db_sg" {
        name            = "mysql_ssh"
        description     = "For db server"
        vpc_id          = "${data.aws_vpc.selected.id}" #Default VPC id here

        ingress { #MYSQL Port
                from_port       = 3306
                to_port         = 3306
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]
        }

        ingress { #SSH Port
                from_port       = 22
                to_port         = 22
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]
        }

        egress  { #Outbound all allow
                from_port       = 0
                to_port         = 0
                protocol        = -1
                cidr_blocks     = ["0.0.0.0/0"]
        }

        tags {
                Name            = "MYSQL-SSH"
        }
}

        #Create new aws security group for appliaction instance. Only HTTPS,HTTP and SSH ports is open for outside.
resource "aws_security_group" "app_sg" {
        name            = "ssh_http_https"
        description     = "For web and ssh access"
        vpc_id          = "${data.aws_vpc.selected.id}" #Default VPC id here

        ingress {  #HTTP Port
                from_port       = 80
                to_port         = 80
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }
        ingress {  #SSH Port
                from_port       = 22
                to_port         = 22
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }

        ingress {  #HTTPS Port
                from_port       = 443
                to_port         = 443
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }

        egress  {  #Outbound all allow
                from_port       = 0
                to_port         = 0
                protocol        = -1
                cidr_blocks     = ["0.0.0.0/0"]
        }

        tags {
                Name    = "SSH-HTTP-HTTPS"
        }

}

        #Application instance. 
resource "aws_instance" "app_wm" {
        ami = "${var.latest_redhat}"  #AMI defined in variables.tf file
        instance_type = "${var.server_instance_type}"  #Instance type defined in variables.tf file
        key_name = "Linux-Frankfurt" #KeyPair name to be attached to the instance. Forgot to add in variables :D
        vpc_security_group_ids = ["${aws_security_group.app_sg.id}"]    #Security group id which we already created

        tags {
            Name = "App"
        }
                #Because AWS instance needs some time to be ready for usage we will use below trick with remote-exec. 
                #As per documentation remote-exec waits for successful connection and only after this runs command. 
          provisioner "remote-exec" {
                inline = ["sudo hostname"]

                connection {
                        type        = "ssh"
                        user        = "ec2-user"
                        private_key = "${file(var.ssh_private_key)}"
                }
        }
        
                #local-exec runs our app server related playbook
         provisioner "local-exec" {
                command ="ansible-playbook -i ec2.py app.yml --private-key=Linux-Frankfurt.pem --user ec2-user"
        }

}

