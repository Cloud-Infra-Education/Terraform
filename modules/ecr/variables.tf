variable "ecr_replication_repo_prefixes" {
  description = "Repository prefixes to replicate from Seoul to Oregon (PREFIX_MATCH)"
  type        = list(string)
}
