terraform {
	backend "s3" {
		bucket = "example-state-frontend"   # Change to your S3 bucket name
		key    = "seifeddine/terraform.tfstate"             # Path within the bucket
		region = "us-east-1"                     # Change to your AWS region
		encrypt = true
        use_lockfile = true
	}
}
