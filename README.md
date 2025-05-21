Static Website Hosting Using Terraform & AWS S3
This project demonstrates how I created a static website hosted on AWS S3 using Terraform. The goal was to gain hands-on experience with Terraform and its infrastructure-as-code capabilities while learning how to provision AWS resources programmatically. Through this project, I explored the core concepts of Terraform such as providers, resources, state management, and configuration syntax.

🛠️ What I Learned:
Installing and configuring Terraform

Working with AWS CLI for cloud resource management

Defining infrastructure as code using Terraform

Hosting a static website on AWS S3

Managing public access, static site settings, and bucket policies

📌 Steps Followed:
Step 1: Open your Terraform workspace and begin by creating a provider.tf file to define the AWS provider and region.

Step 2: Run terraform init to initialize the workspace and install all required dependencies and provider plugins.

Step 3: Create a main.tf file to define your AWS resources for hosting the static site.

Step 4: Define an aws_s3_bucket resource with a unique bucket name like mybucket, and set the bucket ownership control to the bucket owner.

Step 5: Update the bucket's public access settings by disabling the "Block all public access" option to allow public website hosting.

Step 6: Enable static website hosting by adding the website block inside the S3 bucket configuration.

Step 7: Upload your website files (such as index.html and error.html) as S3 objects so the bucket has content to serve.

Step 8: Create and style the index.html and error.html files with basic structure and animations.

Step 9: Finally, configure the aws_s3_bucket_website_configuration resource to handle request routing and response for the static website.

