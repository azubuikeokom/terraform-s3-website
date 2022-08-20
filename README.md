# Project Description
This project demonstrates the power of building and setting up CI/CD pipeplines with terraform and circleci by deploying aws s3 bucket, enabling static web hosting capabilities and uploading static files to the bucket.

## Tools
* Git
* Github
* Terraform
* Circleci
* Linux shell scripts

## Objectives
* Setup a CI/CD pipeline to automate code deployment to aws cloud using Git,Github and Circleci automation server
* Terraform as an IaC tool is used to deploy and confiure both AWS S3 bucket for static web hosting, and AWS cloudfront for content distributed network.

## Deployment Process
The following steps describes the process involved in deploying a static website to S3 bucket and linking S3 endpoint to cloudfront for better experience and reachability from any where in the world.
1. Repository is created on github and cloned to local machine.
2. Create ".circleci" folder in root directory of just cloned repo
3. Channge to ".circleci" folder and create a config.yml file-to be auto-discovered by circleci server
4. Create main.tf file and write terraform code to create both S3 bucket and cloudfront services on AWS
5. Create "frontend-files" folder and in it, create both index.html and styles.css files
6. Add readme.md file
7. Commit and push code to github
8. Link github account to circleci
9. Circleci automatically discovers all project on github account
10. Link project and cirlceci automatically discovers config.yml file within ".circleci" folder
11. Add IAM user profile credentials to circleci project's environment variable- to be used within the container environment when workflow starts running.



