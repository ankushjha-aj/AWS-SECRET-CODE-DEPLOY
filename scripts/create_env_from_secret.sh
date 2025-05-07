#!/bin/bash

REGION="ap-south-1"
SECRET_NAME="my-app-env-secret"
APP_DIR="/home/ubuntu/myapp"

SECRET_CONTENT=$(aws secretsmanager get-secret-value \
  --region $REGION \
  --secret-id $SECRET_NAME \
  --query SecretString \
  --output text)

echo "$SECRET_CONTENT" > "$APP_DIR/.env"

chmod 600 "$APP_DIR/.env"
