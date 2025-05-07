# AWS CodePipeline Deployment Guide

This repository contains code for deploying an application to an EC2 instance using AWS CodePipeline with Secrets Manager integration.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **GitHub Account** with this repository cloned/forked
3. **Basic knowledge** of AWS services and Git

## Step 1: Set Up AWS IAM User

1. Sign in to the AWS Management Console
2. Navigate to IAM (Identity and Access Management)
3. Create a new IAM user with programmatic access
4. Attach the following policies:
   - AmazonEC2FullAccess
   - AmazonS3FullAccess
   - AmazonCodeDeployFullAccess
   - AWSCodePipelineFullAccess
   - AmazonSecretsManagerReadWrite
5. Save the Access Key ID and Secret Access Key securely

## Step 2: Configure AWS CLI

1. Install AWS CLI on your local machine:
   - [Windows](https://awscli.amazonaws.com/AWSCLIV2.msi)
   - [macOS](https://awscli.amazonaws.com/AWSCLIV2.pkg)
   - Linux: `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install`

2. Configure AWS CLI with your credentials:
   ```bash
   aws configure
   ```
   - Enter your Access Key ID, Secret Access Key, default region (e.g., ap-south-1), and output format (json)

## Step 3: Launch EC2 Instance

1. Navigate to EC2 in the AWS Management Console
2. Click "Launch Instance"
3. Select Ubuntu Server 20.04 LTS
4. Choose instance type (t2.micro is free tier eligible)
5. Configure instance details:
   - Network: Default VPC
   - Subnet: Choose a public subnet
   - Auto-assign Public IP: Enable
6. Add storage (default 8GB is sufficient)
7. Add tags:
   - Key: Name
   - Value: MyAppServer
8. Configure security group:
   - Allow SSH (port 22) from your IP
   - Allow HTTP (port 80) from anywhere
   - Allow HTTPS (port 443) from anywhere
9. Review and launch with a new or existing key pair (save the .pem file securely)

## Step 4: Set Up Secrets Manager

1. Navigate to AWS Secrets Manager
2. Click "Store a new secret"
3. Select "Other type of secret"
4. Enter your secret key-value pairs that will form your .env file content:
   ```
   KEY1=value1
   KEY2=value2
   ```
5. Secret name: `my-app-env-secret`
6. Add description (optional)
7. Use default encryption key
8. Configure automatic rotation (optional)
9. Review and store the secret

## Step 5: Set Up CodeDeploy

1. Navigate to AWS CodeDeploy
2. Create application:
   - Application name: MyApp
   - Compute platform: EC2/On-premises
3. Create deployment group:
   - Deployment group name: MyApp-DeploymentGroup
   - Service role: Create a new service role or select existing with proper permissions
   - Deployment type: In-place
   - Environment configuration: Select your EC2 instance by tag
   - Deployment settings: CodeDeployDefault.AllAtOnce
   - Load balancer: Uncheck (unless you need it)

## Step 6: Set Up S3 Bucket for Artifacts

1. Navigate to S3
2. Create bucket:
   - Bucket name: myapp-codepipeline-artifacts-XXXX (replace XXXX with unique identifier)
   - Region: Same as your EC2 instance
   - Block all public access: Yes
   - Keep default settings for the rest
   - Create bucket

## Step 7: Set Up CodePipeline

1. Navigate to AWS CodePipeline
2. Create pipeline:
   - Pipeline name: MyApp-Pipeline
   - Service role: New service role
   - Role name: AWSCodePipelineServiceRole-MyApp
   - Artifact store: Default location
3. Source stage:
   - Source provider: GitHub (Version 2)
   - Connect to GitHub and select your repository
   - Branch name: main
   - Detection options: GitHub webhooks
4. Build stage: Skip (we don't need a build stage for this simple app)
5. Deploy stage:
   - Deploy provider: AWS CodeDeploy
   - Region: Same as your EC2 instance
   - Application name: MyApp
   - Deployment group: MyApp-DeploymentGroup
6. Review and create pipeline

## Step 8: Configure EC2 Instance For CodeDeploy

1. SSH into your EC2 instance:
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-public-ip
   ```

2. Install CodeDeploy agent:
   ```bash
   # Update package lists
   sudo apt-get update
   
   # Install dependencies
   sudo apt-get install -y ruby wget
   
   # Download and install CodeDeploy agent
   cd /home/ubuntu
   wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
   chmod +x ./install
   sudo ./install auto
   sudo service codedeploy-agent status
   ```

3. Install AWS CLI for Secrets Manager access:
   ```bash
   # Install AWS CLI
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

4. Attach IAM role to EC2 instance:
   - In AWS Console, go to EC2 → Instances
   - Select your instance
   - Actions → Security → Modify IAM role
   - Create or select a role with AmazonS3ReadOnlyAccess, AmazonSSMReadOnlyAccess, and SecretsManagerReadWrite permissions

## Step 9: Deploy Your Application

1. Make changes to your application code
2. Commit and push to your GitHub repository
3. CodePipeline will automatically detect changes and deploy to your EC2 instance
4. During deployment, the `create_env_from_secret.sh` script will pull environment variables from Secrets Manager

## Verification and Troubleshooting

1. Check deployment status in CodePipeline console
2. SSH into your EC2 instance to verify deployment:
   ```bash
   # Check if files were deployed
   ls -la /home/ubuntu/myapp
   
   # Check if .env file was created
   cat /home/ubuntu/myapp/.env
   
   # Check CodeDeploy agent logs for errors
   sudo less /var/log/aws/codedeploy-agent/codedeploy-agent.log
   ```

3. Common issues:
   - Incorrect IAM permissions
   - Security group rules not allowing traffic
   - CodeDeploy agent not running
   - Incorrect appspec.yml configuration

## Additional Resources

- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)
- [AWS CodeDeploy Documentation](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html)
- [AWS Secrets Manager Documentation](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
