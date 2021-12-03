provider "aws" {
  region  = "eu-west-1"
  profile = "privateGmail"
  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias   = "ap-southeast-1"
  region  = "ap-southeast-1"
  profile = "privateGmail"
  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "privateGmail"
  default_tags {
    tags = local.default_tags
  }
}