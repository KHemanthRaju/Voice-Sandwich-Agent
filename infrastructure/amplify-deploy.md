# AWS Amplify Frontend Deployment Guide

## Prerequisites
1. AWS Account with Amplify access
2. GitHub/GitLab repository with your code
3. Backend already deployed via CloudFormation

## Step 1: Update Frontend Configuration

Update `components/web/src/App.tsx` to use the WebSocket URL from your CloudFormation deployment:

```typescript
// Replace the hardcoded localhost URL with your CloudFormation WebSocket URL
const WEBSOCKET_URL = import.meta.env.VITE_WEBSOCKET_URL || 'wss://your-api-id.execute-api.us-west-2.amazonaws.com/prod';
```

Create `components/web/.env.production`:
```bash
VITE_WEBSOCKET_URL=wss://YOUR_API_GATEWAY_ID.execute-api.us-west-2.amazonaws.com/prod
```

## Step 2: Deploy to AWS Amplify

### Option A: Using AWS Console

1. Go to AWS Amplify Console: https://console.aws.amazon.com/amplify/
2. Click "New app" → "Host web app"
3. Connect your Git repository (GitHub/GitLab/Bitbucket)
4. Configure build settings:

```yaml
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - cd components/web
        - npm ci
    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: components/web/dist
    files:
      - '**/*'
  cache:
    paths:
      - components/web/node_modules/**/*
```

5. Add environment variable:
   - Key: `VITE_WEBSOCKET_URL`
   - Value: Your WebSocket URL from CloudFormation output

6. Click "Save and deploy"

### Option B: Using Amplify CLI

```bash
# Install Amplify CLI
npm install -g @aws-amplify/cli

# Initialize Amplify in your project
cd components/web
amplify init

# Add hosting
amplify add hosting

# Select: "Hosting with Amplify Console"
# Select: "Continuous deployment"

# Configure environment variables
amplify env add production
amplify env set VITE_WEBSOCKET_URL wss://your-api-id.execute-api.us-west-2.amazonaws.com/prod

# Deploy
amplify publish
```

## Step 3: Configure Custom Domain (Optional)

1. In Amplify Console, go to "Domain management"
2. Add your custom domain (e.g., voicesandwich.yourdomain.com)
3. Follow DNS configuration instructions
4. SSL certificate will be automatically provisioned

## Step 4: Set up CI/CD

Amplify automatically sets up CI/CD from your Git repository:
- Every push to `main` branch triggers a new deployment
- Pull requests create preview environments
- Automatic build and deploy on merge

## Architecture Overview

```
┌─────────────────────────────────────────┐
│   AWS Amplify (Frontend Hosting)        │
│   - React/Vite App                      │
│   - CDN Distribution (CloudFront)        │
│   - SSL Certificate                      │
│   - Custom Domain                        │
└─────────────────────────────────────────┘
              ↓ WebSocket
┌─────────────────────────────────────────┐
│   API Gateway WebSocket                  │
│   ↓                                      │
│   Lambda Function                        │
│   - Voice Agent Logic                    │
│   - STT/Agent/TTS Pipeline              │
└─────────────────────────────────────────┘
```

## Environment Variables

Make sure to set these in Amplify:
- `VITE_WEBSOCKET_URL`: Your WebSocket API URL from CloudFormation

## Monitoring

- **Amplify Console**: View build logs and deployment status
- **CloudWatch**: Monitor Lambda function logs
- **API Gateway Metrics**: Track WebSocket connections and errors

## Cost Optimization

- Amplify Free Tier: 1000 build minutes/month, 15 GB served/month
- Consider enabling compression and caching
- Use CloudFront edge locations for global distribution
- Set up budget alerts in AWS Billing
