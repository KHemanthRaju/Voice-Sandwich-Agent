# Voice Sandwich AWS Deployment

Complete guide for deploying the Voice Sandwich application to AWS using CloudFormation and Amplify.

## Architecture

- **Frontend**: AWS Amplify (React/Vite web app with CDN distribution)
- **Backend**: AWS Lambda + API Gateway WebSocket
- **AI Services**: AWS Bedrock (Claude), AssemblyAI (STT), Cartesia (TTS)
- **Secrets**: AWS Secrets Manager

## Quick Start

### 1. Deploy Backend (CloudFormation)

```bash
# Make script executable
chmod +x infrastructure/deploy.sh

# Deploy backend infrastructure
./infrastructure/deploy.sh
```

This will:
- Build the TypeScript Lambda function
- Create S3 bucket for deployment artifacts
- Deploy CloudFormation stack with:
  - Lambda function
  - API Gateway WebSocket
  - Secrets Manager for API keys
  - IAM roles and permissions

### 2. Deploy Frontend (Amplify)

Follow the guide in [amplify-deploy.md](./amplify-deploy.md)

## Manual Deployment

### Backend (CloudFormation)

```bash
# 1. Build Lambda package
cd components/typescript
pnpm install && pnpm run build

# 2. Create deployment package
mkdir -p ../../infrastructure/lambda-package
cp -r dist ../../infrastructure/lambda-package/
cp -r node_modules ../../infrastructure/lambda-package/
cp package.json ../../infrastructure/lambda-package/
cd ../../infrastructure/lambda-package
zip -r ../lambda-function.zip .
cd ..

# 3. Upload to S3
aws s3 cp lambda-function.zip s3://your-deployment-bucket/

# 4. Deploy CloudFormation
aws cloudformation deploy \
  --template-file cloudformation-template.yaml \
  --stack-name voice-sandwich-backend \
  --parameter-overrides \
      AssemblyAIAPIKey="your-key" \
      CartesiaAPIKey="your-key" \
  --capabilities CAPABILITY_IAM \
  --region us-west-2

# 5. Get WebSocket URL
aws cloudformation describe-stacks \
  --stack-name voice-sandwich-backend \
  --query 'Stacks[0].Outputs[?OutputKey==`WebSocketURL`].OutputValue' \
  --output text
```

### Frontend (Amplify CLI)

```bash
cd components/web

# Install dependencies
pnpm install

# Build for production
pnpm run build

# Deploy to Amplify
amplify init
amplify add hosting
amplify publish
```

## Configuration

### Environment Variables

**Backend (Lambda):**
- Automatically loaded from Secrets Manager
- Configure in CloudFormation parameters

**Frontend (Amplify):**
```bash
VITE_WEBSOCKET_URL=wss://your-api-id.execute-api.us-west-2.amazonaws.com/prod
```

### AWS Credentials

The Lambda function needs:
- Bedrock access (for Claude models)
- Secrets Manager access (for API keys)

These are automatically configured in the CloudFormation template.

## Monitoring & Logs

```bash
# Lambda logs
aws logs tail /aws/lambda/voice-sandwich-agent --follow

# API Gateway logs
aws logs tail /aws/apigateway/voice-sandwich-websocket --follow

# Amplify deployment logs
# View in AWS Console → Amplify → App → Deployments
```

## Cost Estimation

**Monthly costs (approximate):**
- AWS Lambda: ~$5-20 (depending on usage)
- API Gateway WebSocket: ~$1 per million messages
- Amplify Hosting: Free tier covers ~1000 build minutes, 15GB served
- Secrets Manager: $0.40 per secret per month
- Bedrock: Pay per token (varies by model)
- AssemblyAI: External service, check their pricing
- Cartesia: External service, check their pricing

**Total estimated cost**: $10-50/month for light usage

## Scaling Considerations

- **Lambda**: Auto-scales to handle concurrent requests
- **API Gateway WebSocket**: Supports up to 125,000 concurrent connections
- **Amplify**: Global CDN with automatic scaling
- **Bedrock**: Managed service, auto-scales

For production workloads:
1. Enable API Gateway throttling
2. Set Lambda concurrency limits
3. Monitor costs with AWS Cost Explorer
4. Set up CloudWatch alarms

## Security Best Practices

1. **Use Secrets Manager** for all API keys (done by default)
2. **Enable CloudTrail** for audit logging
3. **Set up VPC** for Lambda if handling sensitive data
4. **Enable WAF** on API Gateway for DDoS protection
5. **Use least privilege IAM roles** (configured in template)
6. **Enable CloudWatch Logs encryption**

## Troubleshooting

### Lambda timeout errors
- Increase Lambda timeout in CloudFormation template (max 15 minutes)
- Check CloudWatch logs for errors

### WebSocket connection issues
- Verify CORS settings in API Gateway
- Check Lambda execution role permissions
- Verify Secrets Manager access

### Frontend not connecting
- Verify VITE_WEBSOCKET_URL environment variable
- Check browser console for errors
- Verify API Gateway deployment stage

## Cleanup

To delete all resources:

```bash
# Delete CloudFormation stack
aws cloudformation delete-stack --stack-name voice-sandwich-backend

# Delete Amplify app
amplify delete

# Delete S3 deployment bucket
aws s3 rb s3://voice-sandwich-deployment-ACCOUNT_ID --force
```

## Support

For issues or questions:
1. Check CloudWatch Logs
2. Review AWS Console for service status
3. Verify all API keys are correct in Secrets Manager
