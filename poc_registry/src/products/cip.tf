variable "aws_region" {
    type = "string"
}

variable "instance_type" {
    type = "string"
}

variable "rdp_username" {
  type    = "string"
  default = "Administrator"
}

variable "rdp_password" {
  type    = "string"
  default = "Merck2017"
}

provider "aws" {
    region = "${var.aws_region}"
}

resource "random_string" "name_suffix" {
    length = 5
    special = false
}

resource "aws_security_group" "poc-sec-group" {
    description = "Sec group created for a Service catalog POC"
    vpc_id      = "vpc-0750f1ed60b9a1766"

    ingress {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        # Please restrict your ingress to only necessary IPs and ports.
        # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "virtual-machine" {
    ami = "ami-048e4c9ced23b53f7"

    instance_type = "${var.instance_type}"

    associate_public_ip_address = true
    subnet_id = "subnet-0a86c835896879945"
    vpc_security_group_ids = ["${aws_security_group.poc-sec-group.id}"]
}

output "instance_id"{
    value = "${aws_instance.virtual-machine.*.id[0]}"
}

output "public_ip"{
    value = "${aws_instance.virtual-machine.*.public_ip[0]}"
}

output "rdp_connection_string"{
    value = "${format("rdp://%s:3389", aws_instance.virtual-machine.*.public_ip[0])}"
}

output "public_dns"{
    value = "${aws_instance.virtual-machine.*.public_dns[0]}"
}

output "rdp_username" {
    value = "${var.rdp_username}"
}

output "rdp_password" {
    value = "${var.rdp_password}"
}
