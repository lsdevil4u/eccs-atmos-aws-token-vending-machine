terraform {
  backend "s3" {
    key            = "github/Sanofi-GitHub/eccs-atmos-aws-token-vending-machine/tvm_uit_tests.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}
