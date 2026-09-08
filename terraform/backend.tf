terraform {
  backend "s3" {
    bucket       = "devsecops-interview"
    key          = "devsecops-interview-lab/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}