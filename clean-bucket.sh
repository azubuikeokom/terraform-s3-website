#! /bin/bash
aws s3 rm s3://cloudess-bucket/styles.css --profile udacity3  
aws s3 rm s3://cloudess-bucket/index.html --profile udacity3  
aws s3api delete-bucket --bucket cloudess-bucket --profile udacity3
