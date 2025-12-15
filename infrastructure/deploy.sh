#!/bin/bash
set -e

echo "🚀 Voice Sandwich Deployment Script"
echo "===================================="

# Configuration
STACK_NAME="voice-sandwich-backend"
REGION="${AWS_REGION:-us-west-2}"
TEMPLATE_FILE="infrastructure/cloudformation-template.yaml"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first."
    exit 1
fi

# Check if user is logged in
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Not authenticated with AWS. Please run 'aws configure' first."
    exit 1
fi

echo ""
echo "📦 Step 1: Building Lambda package..."
cd components/typescript
pnpm install
pnpm run build
cd ../..

# Create deployment package
mkdir -p infrastructure/lambda-package
cp -r components/typescript/dist infrastructure/lambda-package/
cp -r components/typescript/node_modules infrastructure/lambda-package/
cp components/typescript/package.json infrastructure/lambda-package/

echo ""
echo "📤 Step 2: Packaging Lambda function..."
cd infrastructure/lambda-package
zip -r ../lambda-function.zip . -q
cd ../..

# Upload to S3 (create bucket if needed)
S3_BUCKET="voice-sandwich-deployment-$(aws sts get-caller-identity --query Account --output text)"
if ! aws s3 ls "s3://${S3_BUCKET}" 2>&1 > /dev/null; then
    echo "Creating S3 bucket: ${S3_BUCKET}"
    aws s3 mb "s3://${S3_BUCKET}" --region ${REGION}
fi

aws s3 cp infrastructure/lambda-function.zip "s3://${S3_BUCKET}/lambda-function.zip"

echo ""
echo "🔑 Step 3: Enter API Keys (they will be stored securely in AWS Secrets Manager)"
read -sp "AssemblyAI API Key: " ASSEMBLYAI_KEY
echo ""
read -sp "Cartesia API Key: " CARTESIA_KEY
echo ""
read -sp "Anthropic API Key (optional, press Enter to skip): " ANTHROPIC_KEY
echo ""
read -sp "OpenAI API Key (optional, press Enter to skip): " OPENAI_KEY
echo ""

echo ""
echo "☁️  Step 4: Deploying CloudFormation stack..."
aws cloudformation deploy \
    --template-file ${TEMPLATE_FILE} \
    --stack-name ${STACK_NAME} \
    --parameter-overrides \
        AssemblyAIAPIKey="${ASSEMBLYAI_KEY}" \
        CartesiaAPIKey="${CARTESIA_KEY}" \
        AnthropicAPIKey="${ANTHROPIC_KEY}" \
        OpenAIAPIKey="${OPENAI_KEY}" \
    --capabilities CAPABILITY_IAM \
    --region ${REGION}

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Stack Outputs:"
aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} \
    --region ${REGION} \
    --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
    --output table

# Get WebSocket URL
WEBSOCKET_URL=$(aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} \
    --region ${REGION} \
    --query 'Stacks[0].Outputs[?OutputKey==`WebSocketURL`].OutputValue' \
    --output text)

echo ""
echo "🌐 WebSocket URL: ${WEBSOCKET_URL}"
echo ""
echo "Next steps:"
echo "1. Update your frontend to use this WebSocket URL"
echo "2. Deploy frontend to AWS Amplify (see amplify-deploy.md)"
