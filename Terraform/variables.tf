variable "region" {
   type          = string
   description   = "Region where we will create our resources"
   default       = "eu-west-3"
}

#Availability zones
variable "azs" {
  type          = list(string)
  description   = "Availability zones"
  default       = ["eu-west-3a, eu-west-3b, eu-west-3c"]
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = 256
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = 512
}