variable "ssh_private_key" {
        default         = "sydney.pem"
        description     = "Private key for sydney region"
}

variable "server_instance_type" {
        default         = "t2.micro"
        description     = "Instance type"
}

variable "access_key" {
        default         = "YOUR_IAM_ACCESS_KEY_HERE"
        description     = "IAM Access Key"
}

variable "secret_key" {
        default         = "YOUR_IAM_SECRET_KEY_HERE"
        description     = "IAM Secret Key"
}

variable "latest_redhat" {
        default         = "ami-044c46b1952ad5861"
        description     = "Latest Redhat AMI"
}

variable "region" {
        default         = "ap-southeast-2"
        description     = "AWS Region"
}

