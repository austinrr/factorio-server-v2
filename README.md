# factorio-server-v2

## required s3 bucket policy
[source](https://docs.docker.com/registry/storage-drivers/s3/)
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:ListBucketMultipartUploads"
      ],
      "Resource": "arn:aws:s3:::S3_BUCKET_NAME"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Resource": "arn:aws:s3:::S3_BUCKET_NAME/*"
    }
  ]
}
```

## installing docker on AMI
1. update packages `[ec2-user ~]$ sudo yum update -y`
2. install docker `[ec2-user ~]$ sudo yum install docker -y`
3. start docker service `[ec2-user ~]$ sudo service docker start`
4. add `ec2-user` to docker group for executing w/o sudo `[ec2-user ~]$ sudo usermod -a -G docker ec2-user`