data "http" "local_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "terraform_data" "local_cidr" {
  input = "${trimspace(data.http.local_ip.response_body)}/32"
}
