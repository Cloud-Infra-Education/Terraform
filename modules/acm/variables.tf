#--------------------------------
variable "our_team" {
  type = string
}
#--------------------------------
variable "www_subdomain" {
  type    = string
  default = "www"
}
variable "api_subdomain" {
  type    = string
  default = "api"
}
variable "domain_name" {
  type = string
}
#--------------------------------
variable "origin_bucket_name" {
  type = string
}
variable "origin_bucket_region" {
  type    = string
  default = "ap-northeast-2"
}

