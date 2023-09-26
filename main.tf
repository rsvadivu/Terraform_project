terraform {
  backend "s3" {
    bucket = "rsvadivu-terraform-state-bucket1"
    key    = "path/terraform.tfstate"
    region = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

# resource "aws_instance" "web" {
#   ami           = "ami-024e6efaf93d85776"
#   instance_type = "t2.micro"
#   key_name = "Linux-demo-key"

#   tags = {
#     Name = "Terraform Instance"
#   }
# }
# resource "aws_eip" "lb" {
#   instance = aws_instance.web.id
 
# }

#creating the new infrastructure

resource "aws_vpc" "east-2" {
  cidr_block = "10.10.0.0/16"
  tags ={ 
    Name= "US-east-2"
  }
  }

  resource "aws_subnet" "east-subnet-1a" {
    vpc_id = aws_vpc.east-2.id
    cidr_block = "10.10.0.0/24"
    availability_zone = "us-east-2a"
    map_public_ip_on_launch = "true"
    tags = {
      Name="east-subnet-2a"
    }
  }
  resource "aws_subnet" "east-subnet-1b" {
    vpc_id = aws_vpc.east-2.id
    cidr_block = "10.10.1.0/24"
    availability_zone = "us-east-2b"
    map_public_ip_on_launch = "true"
    tags = {
      Name="east-subnet-2b"
    }
  }
   resource "aws_subnet" "east-subnet-1c" {
    vpc_id = aws_vpc.east-2.id
    cidr_block = "10.10.2.0/24"
    availability_zone = "us-east-2c"
    map_public_ip_on_launch = "true"
    tags = {
      Name="east-subnet-2c"
    } 
  }


  ##instance

  resource "aws_instance" "web1" {
  ami           = "ami-024e6efaf93d85776"
  instance_type = "t2.micro"
  key_name = aws_key_pair.east2.id
  subnet_id = aws_subnet.east-subnet-1a.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  tags = {
    Name = "Instance01-subnet1a"
  }
}

 resource "aws_instance" "web2" {
  ami           = "ami-024e6efaf93d85776"
  instance_type = "t2.micro"
  key_name = aws_key_pair.east2.id
  subnet_id = aws_subnet.east-subnet-1a.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  tags = {
    Name = "Instance02-subnet1a"
  }
}

#  resource "aws_instance" "web3" {
#   ami           = "ami-03704e8ae3d75de26"
#   instance_type = "t2.micro"
#   key_name = aws_key_pair.east2.id
#   subnet_id = aws_subnet.east-subnet-1a.id
#   vpc_security_group_ids = [aws_security_group.allow_tls.id]

#   tags = {
#     Name = "Instance02-subnet1a-1"
#   }
# }

##keypair
resource "aws_key_pair" "east2" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6yMe4PYLbrBsVrjN7x8OMPm32cqEK6VqU7XnfcIRsoeEiQddpSbmjYvMYbKm+xdvqOTO7Xt2OUo47jwhai6qGI8EYTZ/f2Dj+CK0GMjq4XLoh5NOqdCZVHCRhl3keQJf5f7tukSHkJqnqpwwYAQFVzkfzd5K8QwBQfTZi1ckYcNVHUzQsKQKyQn6R9IvRUDxO0l3R2InF2u64Lh8iqdShIzocaNBZLgmh1iCloxjnw5vxtCf2jSM8/Xe9fOmeWYA5xXR1TOetoyfLVed8bpQaQEeiq4TGK8tZJ9XxH4vGKnPzQulChLJbqMzPyEcCoX3Ve9xUBJ4EPJQkH2hXx5F7AetGIQIEn0LT1RB8GkPZKD3Mmq5MTQcf2e0roa3CCGV3kttQdIrDAYRB1RRAxVx4cFWsd14QLdVq2LGZjXrtqtz6gP5KAXGJoq2fPCICRGsBhP1V44TWpgjcaD+9JVZovUwUto512R2KeJhg0YXtsatOGeLsmsYO2jWO8jxDNPE= aegan@DESKTOP-HJIRGB9"
}

#security group

resource "aws_security_group" "allow_tls" {
  name        = "allow_http_ssh"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.east-2.id

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}


##create Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.east-2.id

  tags = {
    Name = "MyIG"
  }
}

#Creating Route table

resource "aws_route_table" "us-east-2RT-public" {
  vpc_id = aws_vpc.east-2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

   tags = {
    Name = "us-east-2RT-public"
  }
}

resource "aws_route_table" "us-east-2RT-private" {
  vpc_id = aws_vpc.east-2.id

 

  tags = {
    Name = "us-east-2RT-private"
  }
}

# Associate the routetable to subnet

resource "aws_route_table_association" "RT_asso_1a" {
  subnet_id      = aws_subnet.east-subnet-1a.id
  route_table_id = aws_route_table.us-east-2RT-public.id
}

resource "aws_route_table_association" "RT_asso_1b" {
  subnet_id      = aws_subnet.east-subnet-1b.id
  route_table_id = aws_route_table.us-east-2RT-public.id
}

resource "aws_route_table_association" "RT_asso_1c" {
  subnet_id      = aws_subnet.east-subnet-1c.id
  route_table_id = aws_route_table.us-east-2RT-private.id
}

#Target Group


resource "aws_lb_target_group" "card-website-TG-Terraform" {
  name     = "card-website-TG-Terraform"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.east-2.id
}

resource "aws_lb_target_group_attachment" "TG-instance-1" {
  target_group_arn = aws_lb_target_group.card-website-TG-Terraform.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "TG-instance-2" {
  target_group_arn = aws_lb_target_group.card-website-TG-Terraform.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

# resource "aws_lb_target_group_attachment" "TG-instance-3" {
#   target_group_arn = aws_lb_target_group.card-website-TG-Terraform.arn
#   target_id        = aws_instance.web3.id
#   port             = 80
# }

# #LB
# resource "aws_lb" "card-website-LB-terraform" {
#   name               = "card-website-LB-terraform"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.allow_tls.id]
#   subnets            = [aws_subnet.east-subnet-1a.id,aws_subnet.east-subnet-1b.id]

#   tags = {
#     Environment = "production"
#   }
# }


# resource "aws_lb_listener" "card-website-listener" {
#   load_balancer_arn = aws_lb.card-website-LB-terraform.arn
#   port              = "80"
#   protocol          = "HTTP"
  

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.card-website-TG-Terraform.arn
#   }
# }

####creating instances via Auto scaling group and we will attach the LB to it
##creating the launch template
# resource "aws_launch_template" "LT-demo-terraform"{
#   name="LT-demo-terraform"
#  image_id = "ami-03704e8ae3d75de26"
#  instance_type = "t2.micro" 
# key_name = aws_key_pair.east2.id
# vpc_security_group_ids = [aws_security_group.allow_tls.id]
# user_data = filebase64("example.sh")
# tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name = "demo-instance using-LT by terraform"
#     }
#   }

# }

# ##Auto scaling GRoup creation
# resource "aws_autoscaling_group" "demo-asg" {
#   vpc_zone_identifier       = [aws_subnet.east-subnet-1a.id, aws_subnet.east-subnet-1b.id]
#   desired_capacity   = 2
#   max_size           = 5
#   min_size           = 2
#   name="demo-asg-terraform"
#   target_group_arns = [aws_lb_target_group.card-website-TG-Terraform-ASG.arn]

#   launch_template {
#     id      = aws_launch_template.LT-demo-terraform.id
#     version = "$Latest"
#   }
# }


# ###Load Balaner  with Terraform

# ##Target Group

# resource "aws_lb_target_group" "card-website-TG-Terraform-ASG" {
#   name     = "card-website-TG-Terraform-ASG"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.east-2.id
# }

# ###LB
# resource "aws_lb" "card-website-LB-terraform-ASG" {
#   name               = "card-website-LB-terraform-ASG"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.allow_tls.id]
#   subnets            = [aws_subnet.east-subnet-1a.id,aws_subnet.east-subnet-1b.id]

#   tags = {
#     Environment = "production"
#   }
# }

# ### Listener
# resource "aws_lb_listener" "card-website-listener-ASG" {
#   load_balancer_arn = aws_lb.card-website-LB-terraform-ASG.arn
#   port              = "80"
#   protocol          = "HTTP"
  

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.card-website-TG-Terraform-ASG.arn
#   }
# }



