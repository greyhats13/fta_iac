resource "random_password" "jdbc_password" {
  length           = 12
  override_special = "!#$%&*@"
  min_lower        = 3
  min_upper        = 3
  min_numeric      = 3
  min_special      = 0
}

resource "random_password" "admin_password" {
  length           = 12
  override_special = "!#$%&*@"
  min_lower        = 3
  min_upper        = 3
  min_numeric      = 3
  min_special      = 0
}