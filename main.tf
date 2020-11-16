
provider "aws" {
        region = "${var.region}"
        access_key = "${var.access_key}"
        secret_key = "${var.secret_key}"
}

data "aws_vpc" "selected" {
        filter {
                name    = "tag:Name"
                values  = ["default"]
        }
}


resource "aws_security_group" "app_sg" {
        name            = "ssh_http_https"
        description     = "For web and ssh access"
        vpc_id          = "${data.aws_vpc.selected.id}" 
        ingress {  
                from_port       = 3000
                to_port         = 3000
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }
        ingress {  
                from_port       = 22
                to_port         = 22
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }

        ingress {  
                from_port       = 443
                to_port         = 443
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }

        egress  {  
                from_port       = 0
                to_port         = 0
                protocol        = -1
                cidr_blocks     = ["0.0.0.0/0"]
        }

        tags {
                Name    = "SSH-HTTP-HTTPS"
        }

}

         
resource "aws_instance" "app_wm" {
        ami = "${var.latest_redhat}"  
        instance_type = "${var.server_instance_type}"  #
        key_name = "sydney" 
        vpc_security_group_ids = ["${aws_security_group.app_sg.id}"]    

        tags {
            Name = "App"
        }
          provisioner "remote-exec" {
                inline = ["sudo hostname"]

                connection {
                        type        = "ssh"
                        user        = "ec2-user"
                        private_key = "${file(var.ssh_private_key)}"
                }
        }
         provisioner "local-exec" {
                command ="ansible-playbook -i ec2.py app.yml --private-key=sydney.pem --user ec2-user"
        }

}

resource "aws_security_group" "lb_sg" {
        name            = "ssh_http_https"
        description     = "For web and ssh access"
        vpc_id          = "${data.aws_vpc.selected.id}" 
        ingress {  
                from_port       = 3000
                to_port         = 3000
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }
       

        ingress {  
                from_port       = 443
                to_port         = 443
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }

        egress  {  
                from_port       = 0
                to_port         = 0
                protocol        = -1
                cidr_blocks     = ["0.0.0.0/0"]
        }

        tags {
                Name    = "SSH-HTTP-HTTPS"
        }

}

resource "aws_lb" "helloworld" {
  name               = "helloworld-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "helloworld-lb"
    enabled = true
  }

  tags = {
    Environment = "poc"
  }
}

resource "aws_placement_group" "helloworld" {
  name     = "helloworld"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "hello-asg" {
  name                      = "hello-asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  placement_group           = aws_placement_group.helloworld.id
  launch_configuration      = aws_launch_configuration.helloworld.name
  vpc_zone_identifier       = [aws_subnet.example1.id, aws_subnet.example2.id]

  initial_lifecycle_hook {
    name                 = "helloworld"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = <<EOF
{
  "hello": "world"
}
EOF

    notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }

  tag {
    key                 = "hello"
    value               = "world"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}