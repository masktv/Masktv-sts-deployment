
s3 to s3 object copying

Source Bucket Setting :
  1.  source bucket acess : block public acess - off
  2.  source bucket ownership : Bucket owner preferred
  3.  source bucket policy :

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessFromSpecificDomainAndApps",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::masktv2023-1/*",
            "Condition": {
                "StringLike": {
                    "aws:Referer": [
                        "http://masktvott.com/*",
                        "https://masktvott.com/*",
                        "https://web.masktvott.com/*",
                        "http://masktvapp.com/*",
                        "https://masktvapp.com/*",
                        "https://web.masktvapp.com/*",
                        "http://masksouth.com/*",
                        "https://masksouth.com/*",
                        "https://web.masksouth.com/*"
                    ]
                }
            }
        },
        {
            "Sid": "AllowAllPrincipalsForCopy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::masktv2023-1/*"
        }
    ]
}

Destination Bucket Setting:
  1.  Destination bucket acess : block public acess - off
  2.  Destination bucket ownership : Bucket owner preferred
  3.  Destination bucket policy :

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAllPrincipalsToPutObjects",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::test-copy-bucket-1/*"
        }
    ]
}
