resource "random_password" "atlantis_github_secret" {
  length           = 64
  override_special = "!#$%&*@"
  min_lower        = 10
  min_upper        = 10
  min_numeric      = 10
  min_special      = 5
  lifecycle {
    ignore_changes = [result]
  }
}

resource "random_password" "atlantis_password" {
  length           = 12
  override_special = "!#$%&*@"
  min_lower        = 3
  min_upper        = 3
  min_numeric      = 3
  min_special      = 0
  lifecycle {
    ignore_changes = [result]
  }
}

resource "tls_private_key" "atlantis_ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
  lifecycle {
    ignore_changes = [result]
  }
}