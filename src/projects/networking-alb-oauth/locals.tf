locals {
  name_prefix = "albcognito-sbx"
  cidr_prefix = "10.1" # -> 10.1.0.0/16, etc
  region = "ap-southeast-2"
  availability_zones = ["a", "b", "c"]
}
