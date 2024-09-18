# Create the Database
resource "google_sql_database" "database" {
  name      = var.database
  instance  = var.instance_name
  project   = var.project_id
  charset   = var.database_charset
  collation = var.database_collation
}

# Create the User
resource "google_sql_user" "user" {
  name     = var.username
  instance = var.instance_name
  project  = var.project_id
  password = var.password
  host     = var.host
}