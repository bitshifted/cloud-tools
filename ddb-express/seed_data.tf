# Copyright 2026 Bitshift ED (https://www.bitshifted.com)


data "aws_region" "current" {

}

resource "terraform_data" "db_seeder" {
  count = var.seed_data_file_path != null ? 1 : 0

  triggers_replace = {
    file_hash = filesha256(var.seed_data_file_path)
  }

  provisioner "local-exec" {
    command = "${var.aws_cli_command} dynamodb batch-write-item --request-items file://${var.seed_data_file_path} --region ${data.aws_region.current.region}"
  }
}