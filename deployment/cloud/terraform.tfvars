unit                        = "fta"
env                         = "mstr"
region                      = "asia-southeast2"
github_repo                 = "fta_iac"
github_owner                = "greyhats13"
github_orgs                 = "blastcoid"
github_oauth_client_id      = "9781757e794562ceb7e1"
atlantis_version            = "v0.29.0"
atlantis_user               = "atlantis"
argocd_version              = "v2.12.3"
argocd_vault_plugin_version = "1.18.1"
# The following is a list of secrets that are encrypted using the KMS key
iac_secrets_ciphertext = {
  github_token_iac           = "CiQAVucnPlSoVrFW356BVXK9h9ZVPm4bPTVX9heDhVq759X3f4gSUQA4ny4NQIrKNdhCf1d1Dlh9lCIUxkNRl7HPfKAZ0UeLvb8cH19Ru0Zss/1ChBO0MTsBQAi8uQs+ORnGlYr2kK07ZjtJyP+pRE/e0fnCfRzWsw=="
  github_token_atlantis      = "CiQAVucnPr5qKyBOkvYYJ+uPfeQtWvUhnRbVYvMVTW5wH3FuIjYSUQA4ny4N9JrVLRwJS18xd0ZSXjy0iJ/pS6jUlnh4EE4fapDtM31ALvEkNEM/5iX2/U7bwaTpi9YuVT1Lxc955JSEhxZUn83fD0ByMtvv8FkB/A=="
  github_oauth_client_secret = "CiQAVucnPodamJwhIqvM+KAl7yioXUWrKm/epygLNDmKFMvOhhsSUQA4ny4Nj5+dS0DhAUkJRu4if7ICztZZreZ9rJ1IrWPbvIUXYcRFo1SlwdiZzN72B1N6ELSV9drAC9RC551Jzl0CCXl/7Ib50yNjzYLsdKtnpQ=="
}

# Sonarqube
sonarqube_jdbc_user = "sonar"
sonarqube_jdbc_db   = "sonar_db"
sonarqube_jdbc_port = 5432
