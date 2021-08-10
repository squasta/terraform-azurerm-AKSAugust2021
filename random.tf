# cf https://www.terraform.io/docs/providers/random/r/string.html
resource "random_string" "Terra-random" {
  length  = 5
  special = false
}


