# Voice Sandwich Deployment Options

The Voice Sandwich application requires a persistent WebSocket connection, which presents different deployment considerations. Here are the recommended approaches:

## Option 1: AWS Fargate (Recommended for Production)

**Best for:** Scalable, production-ready deployments without managing servers

### Architecture
```
Frontend (Amplify) → ALB → Fargate (ECS) → Bedrock/AssemblyAI/Cartesia
```

### Pros
- ✅ Serverless containers (no server management)
- ✅ Auto-scaling based on load
- ✅ Pay only for what you use
- ✅ Built-in load balancing
- ✅ Supports long-running WebSocket connections

### Deployment Steps

See [fargate-deployment.md](./fargate-deployment.md) for detailed instructions.

**Quick Start:**
```bash
./infrastructure/deploy-fargate.sh
```

**Estimated Cost:** $20-50/month for light usage

---

## Option 2: AWS EC2 with Auto Scaling

**Best for:** Full control, predictable costs

### Architecture
```
Frontend (Amplify) → ALB → EC2 Auto Scaling Group → Bedrock/AssemblyAI/Cartesia
```

### Pros
- ✅ Full control over environment
- ✅ Predictable pricing
- ✅ Can use Reserved Instances for cost savings
- ✅ Easy to SSH and debug

### Deployment Steps

See [ec2-deployment.md](./ec2-deployment.md) for detailed instructions.

**Estimated Cost:** $10-30/month (t3.small Reserved Instance)

---

## Option 3: Lambda + API Gateway WebSocket (Advanced)

**Best for:** Stateless, event-driven architectures

### ⚠️ Limitations
- Lambda has **15-minute timeout**
- Complex state management for WebSockets
- Requires DynamoDB for connection tracking
- More complex architecture

### When to Use
- If you need extreme scalability (1000s of connections)
- If you want to minimize idle costs
- If your use case fits short-lived connections

See [lambda-deployment.md](./lambda-deployment.md) for implementation details.

---

## Option 4: Local Development / Simple VPS

**Best for:** Development, testing, demos

### Simple Deployment
```bash
# Deploy to any server with Node.js
npm install -g pm2
cd components/typescript
pnpm install
pm2 start "pnpm run server" --name voice-sandwich
pm2 save
pm2 startup
```

**Platforms:**
- DigitalOcean Droplet ($6/month)
- Linode ($5/month)
- Railway (Free tier available)
- Fly.io (Free tier available)

---

## Comparison

| Feature | Fargate | EC2 | Lambda | VPS |
|---------|---------|-----|--------|-----|
| **Ease of Setup** | Medium | Medium | Hard | Easy |
| **Scalability** | Auto | Manual/Auto | Auto | Manual |
| **Cost (Light)** | $20-50 | $10-30 | $10-30 | $5-10 |
| **Cost (Heavy)** | $100+ | $50+ | $200+ | $20+ |
| **WebSocket Support** | ✅ Native | ✅ Native | ⚠️ Complex | ✅ Native |
| **Management** | Low | Medium | Low | High |

---

## Recommended Path

### For Production
**Use AWS Fargate** - Best balance of scalability, ease, and cost

### For Development/Testing
**Use local VPS** or **Railway/Fly.io** - Simple and cheap

### For Enterprise
**Use EC2 with Reserved Instances** - Predictable costs at scale

---

## Next Steps

Choose your deployment option above and follow the corresponding guide!
