variable "ssh_private_key" {
        default         = "Linux-Frankfurt.pem"
        description     = "Private key for Frankfurt region"
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
        default         = "ami-c86c3f23"
        description     = "Latest Redhat AMI"
}

variable "region" {
        default         = "eu-central-1"
        description     = "AWS Region"
}