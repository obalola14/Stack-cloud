resource "aws_s3_bucket" "b" {
  bucket = "habeeb-stackbuck1"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }

#object lock
object_lock_configuration {
    object_lock_enabled = "Enabled"
	}
#enabling transfer acceleration
    acceleration_status= "Enabled"
}

#enabling server side encryption
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}
resource "aws_s3_bucket" "habeeb-stackbuck2" {
  bucket = "habeeb-stackbuck2"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

#enabling S3 versioning
resource "aws_s3_bucket" "habeeb-stackbuck3" {
  bucket = "habeeb-stackbuck3"
  acl    = "private"

  versioning {
    enabled = true
  }
}

#enabling server access logging
resource "aws_s3_bucket" "log_bucket" {
  bucket = "habeeb-stack-log-bucket"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "habeeb-stackbuck4" {
  bucket = "habeeb-stackbuck4"
  acl    = "private"

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }
}

#create a new bucket for event configuration
#resource "aws_s3_bucket" "eventbuck" {
 # bucket = "stackevent-habeeb"
#  force_destroy = true
#}
#add event notification to newly created bucket
#resource "aws_s3_bucket_notification" "bucket_notification" {
#  bucket = aws_s3_bucket.eventbuck.id

#  topic {
 #   topic_arn     = aws_sns_topic.s3topic.arn
 #   events        = ["s3:ObjectCreated:*"]
#    filter_suffix = ".log"
 # }
#}

#configure event notification on bucket(stackbuck-habeeb4)
#create an sns topic
resource "aws_sns_topic" "s3topic" {
  name = "habeeb-s3-notification"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": { "Service": "s3.amazonaws.com" },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:habeeb-s3-notification",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.eventbuck.arn}"}
        }
    }]
}
POLICY
}
#create a new bucket for event configuration
resource "aws_s3_bucket" "eventbuck" {
  bucket = "stackevent-habeeb"
  force_destroy = true
}
#add event notification to newly created bucket
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.eventbuck.id

  topic {
    topic_arn     = aws_sns_topic.s3topic.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".log"
  }
}

#configure object-level logging
resource "aws_s3_bucket" "log-bucket" {
  bucket        = "stackobjlogging-habeeb"
  force_destroy = true
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::stackobjlogging-habeeb"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::stackobjlogging-habeeb/AWSLogs/450980460849/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

#enable static website hosting
resource "aws_s3_bucket" "habeeb-stackbuck-webhosting" {
  bucket = "habeeb-stackbuck-webhosting"
  acl    = "public-read"
  policy = file("policy.json")

  website {
    index_document = "index.html"
    error_document = "error.html"
  } 
}

#upload object1 to website bucket
resource "aws_s3_bucket_object" "object1" {
  bucket = "habeeb-stackbuck-webhosting"
  key    = "index.html"
  source = "C:/Users/obalo/Downloads/index.html"
  force_destroy = true
  acl="public-read"
  depends_on = [
    aws_s3_bucket.habeeb-stackbuck-webhosting,
  ]
}
#upload object2 to website bucket
resource "aws_s3_bucket_object" "object2" {
  bucket = "habeeb-stackbuck-webhosting"
  key    = "error.html"
  source = "C:/Users/obalo/Downloads/index.html"
  force_destroy = true
  acl="public-read"
  depends_on = [
    aws_s3_bucket.habeeb-stackbuck-webhosting,
  ]
}
#upload object3 to website bucket
resource "aws_s3_bucket_object" "object3" {
  bucket = "habeeb-stackbuck-webhosting"
  key    = "background.png"
  source = "C:/Users/obalo/Downloads/Stack_IT_Logo.png"
  force_destroy = true
  acl="public-read"
  depends_on = [
    aws_s3_bucket.habeeb-stackbuck-webhosting,
  ]
}
#upload object4 to website bucket
#resource "aws_s3_bucket_object" "object4" {
 # bucket = "habeeb-stackbuck-webhosting"
 # key    = "style.css"
  #source = "D:/stackit/web_files/files/style.css"
  #force_destroy = true
  #acl="public-read"
  #depends_on = [
 #   aws_s3_bucket.web-bucket,
  #]
#}
#upload objects to event notification bucket
resource "aws_s3_bucket_object" "object6" {
  bucket = "stackevent-habeeb"
  key    = "test"
  source = "C:/Users/obalo/Downloads/index.html"
  force_destroy = true
  acl="public-read-write"
  depends_on = [
    aws_s3_bucket.eventbuck,
  ]
}
#upload objects to object-level logging bucket
resource "aws_s3_bucket_object" "object7" {
  bucket = "stackobjlogging-habeeb"
  key    = "test"
  source = "C:/Users/obalo/Downloads/index.html"
  force_destroy = true
  acl="public-read-write"
  depends_on = [
    aws_s3_bucket.log-bucket,
  ]
}