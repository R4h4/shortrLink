locals {
  stage = "dev"
  app   = "shortrLink"

  default_tags = {
    terraform = "true"
    project   = local.app,
    service   = "main"
    stage     = local.stage
  }
}
