

variable "prefix" {
  description = "The prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
}

variable "vnetcidr" {
  description = "The cidr for vnet"
}

variable "subnetcidr" {
  description = "The cidr for subnet"
}

variable "vmsize" {
  description = "The vm series name"
}

variable "usrname" {
  description = "The user name of the VM"
}

variable "passwd" {
  description = "The password of the VM"
}