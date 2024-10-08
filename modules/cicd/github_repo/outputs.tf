# Github repository outputs

output "full_name" {
  value       = github_repository.repo.*.full_name
  description = " A string of the form orgname/reponame."
}

output "name" {
  value       = github_repository.repo.*.name
  description = "The name of the repository."
}


output "html_url" {
  value       = github_repository.repo.*.html_url
  description = "URL to the repository on the web."
}

output "ssh_clone_url" {
  value       = github_repository.repo.*.ssh_clone_url
  description = "URL that can be provided to git clone to clone the repository via SSH."
}

output "http_clone_url" {
  value       = github_repository.repo.*.http_clone_url
  description = "URL that can be provided to git clone to clone the repository via HTTPS."
}

output "git_clone_url" {
  value       = github_repository.repo.*.git_clone_url
  description = "URL that can be provided to git clone to clone the repository anonymously via the git protocol."
}

output "svn_url" {
  value       = github_repository.repo.*.svn_url
  description = "URL that can be provided to svn checkout to check out the repository via GitHub's Subversion protocol emulation."
}

output "node_id" {
  value       = github_repository.repo.*.node_id
  description = "GraphQL global node id for use with v4 API"
}

output "repo_id" {
  value       = github_repository.repo.*.repo_id
  description = "GitHub ID for the repository"
}

output "primary_language" {
  value       = github_repository.repo.*.primary_language
  description = "The primary language of the repository."
}

output "pages" {
  value       = github_repository.repo.*.pages
  description = "The block consisting of the repository's GitHub Pages configuration with the following additional attributes: custom_404_path, html_url, and status."
}

# Github Branch outputs


# Github Autolink reference outputs
output "etag" {
  value       = github_repository_autolink_reference.autolink.*.etag
  description = "An etag representing the autolink reference object."
}
