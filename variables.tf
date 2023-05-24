variable "vpc_cidr" {
    default="10.0.0.0/16"
}

variable "public_cidr" {
    default=["10.0.0.0/24,10.0.1.0/24,10.0.2.0"]
}


variable "private_cidr" {
    default=["10.0.3.0/24,10.0.4.0/24,10.0.5.0"]
}

variable "data_cidr" {
    default=["10.0.6.0/24,10.0.7.0/24,10.0.8.0"]
}

variable "envname" {
    default="dev"
}

