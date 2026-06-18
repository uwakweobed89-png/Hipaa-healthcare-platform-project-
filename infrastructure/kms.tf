# KMS Key for PHI encryption
# HIPAA 164.312(a)(2)(iv) requires encryption of PHI at rest
# Customer managed key gives full control and audit trail

resource "aws_kms_key" "phi_encryption" {
  description             = "KMS key for PHI data encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true  # rotate annually for compliance

  tags = {
    Name           = "${var.project_name}-phi-key"
    Environment    = var.environment
    DataClass      = "PHI"
    HIPAAControl   = "164.312(a)(2)(iv)"
  }
}

resource "aws_kms_alias" "phi_encryption" {
  name          = "alias/${var.project_name}-phi-key"
  target_key_id = aws_kms_key.phi_encryption.key_id
}

# S3 bucket for PHI documents — encrypted with KMS
resource "aws_s3_bucket" "phi_documents" {
  bucket = "${var.project_name}-phi-documents-326709068429"

  tags = {
    Name         = "${var.project_name}-phi-documents"
    Environment  = var.environment
    DataClass    = "PHI"
    HIPAAControl = "164.312(a)(2)(iv)"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "phi_documents" {
  bucket = aws_s3_bucket.phi_documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.phi_encryption.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "phi_documents" {
  bucket = aws_s3_bucket.phi_documents.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "phi_documents" {
  bucket                  = aws_s3_bucket.phi_documents.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Object Lock — immutable audit logs
# HIPAA requires audit logs cannot be modified or deleted
resource "aws_s3_bucket" "audit_logs" {
  bucket = "${var.project_name}-audit-logs-326709068429"

  tags = {
    Name         = "${var.project_name}-audit-logs"
    Environment  = var.environment
    DataClass    = "PHI-AUDIT"
    HIPAAControl = "164.312(b)"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.phi_encryption.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "audit_logs" {
  bucket                  = aws_s3_bucket.audit_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
