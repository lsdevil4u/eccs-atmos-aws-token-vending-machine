terraform {
  backend "s3" {
    bucket         = "eccs-devops-terraform-tfstate-dev"
    key            = "github/Sanofi-ECCS-DevOps/DevOps-Automation/dev_poc_environment.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "sanofi-application-terraform-state-locktable-230559371484"
  }
}
