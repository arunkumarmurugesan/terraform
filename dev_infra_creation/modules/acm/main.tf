resource "aws_acm_certificate" "cert" {
    count = var.acm_creation ? 1 : 0
    private_key       = file("./modules/acm/example-key.pem")
    certificate_body  = file("./modules/acm/example-crt.pem")
    certificate_chain = file("./modules/acm/example-bundle.pem")
  
    tags = merge(
            var.tags,
            map(
                "Name", "${var.projectname}-${var.env}-example"
            )
        )
}


resource "aws_acm_certificate" "example" {
    count = var.acm_creation ? 1 : 0
  domain_name       = "example.com"
  subject_alternative_names = ["*.example.com"]
  validation_method = "DNS"

    tags = merge(
            var.tags,
            map(
                "Name", "${var.projectname}-${var.env}-${var.domain_name}"
            )
        )
}
