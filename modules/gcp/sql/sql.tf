# # Create the Database
# resource "random_password" "atlantis_password" {
#   length           = 12
#   override_special = "!#$%&*@"
#   min_lower        = 3
#   min_upper        = 3
#   min_numeric      = 3
#   min_special      = 0
# }

# resource "google_sql_database" "database" {
#   name      = var.cloudsql_instance_name
#   instance  = data.google_sql_database_instance.instance.name
#   project   = var.project_id
#   charset   = var.database_charset
#   collation = var.database_collation
# }

# # Create the User
# resource "google_sql_user" "user" {
#   name     = var.database
#   instance = data.google_sql_database_instance.instance.name
#   project  = var.project_id
#   password = var.password
#   host     = var.host
# }