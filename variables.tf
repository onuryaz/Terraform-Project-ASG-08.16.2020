variable "cidr_base" {
  default = "10.50"
}

variable "zones" {
  type    = "list"
  default = ["a", "b", "c"]
}

variable "region_name" {

}

variable "secret_key" {

}

variable "access_key" {

}

variable "env_name" {
    
}

variable "web_instance" {

}

variable "AWS_REGION" {
    default = "eu-west-1"
}

variable "AMIS" {
type = "map"
default = {
  us-east-1 = "ami-13be557e"
  us-west-2 = "ami-06b94666"
  eu-west-1 = "ami-844e0bf7"
}
}

variable "autoscaling_group_min_size" {

}

variable "autoscaling_group_max_size" {

}

variable "database_name" {

}

variable "db_user" {

}

variable "db_password" {
  
}