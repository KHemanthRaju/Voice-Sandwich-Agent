# Simple Deployment Guide

The easiest way to deploy your Voice Sandwich application is using **Railway** or **Fly.io** - both offer free tiers and are perfect for WebSocket applications.

## Option 1: Railway (Recommended - Easiest)

Railway is the simplest deployment option with a generous free tier.

### Step 1: Install Railway CLI

```bash
npm install -g @railway/cli
```

### Step 2: Login

```bash
railway login
```

### Step 3: Create Project

```bash
cd /Users/etloaner/hemanth/Voice_sandwich_project/components/typescript
railway init
```

### Step 4: Add Environment Variables

```bash
railway variables set ASSEMBLYAI_API_KEY="your-key"
railway variables set CARTESIA_API_KEY="your-key"
railway variables set AWS_ACCESS_KEY_ID="your-key"
railway variables set AWS_SECRET_ACCESS_KEY="your-key"
railway variables set AWS_REGION="us-west-2"
```

### Step 5: Deploy

```bash
railway up
```

That's it! Railway will:
- ✅ Automatically detect it's a Node.js app
- ✅ Install dependencies
- ✅ Start your server
- ✅ Give you a public URL

### Cost
- **Free tier**: $5 credit/month (enough for development)
- **Paid**: $5-20/month

---

## Option 2: Fly.io (More Control)

Fly.io offers great performance and global distribution.

### Step 1: Install Fly CLI

```bash
curl -L https://fly.io/install.sh | sh
```

### Step 2: Login

```bash
fly auth login
```

### Step 3: Create fly.toml

Create `components/typescript/fly.toml`:

```toml
app = "voice-sandwich"
primary_region = "sjc"

[build]
  builder = "paketobuildpacks/builder:base"

[env]
  PORT = "8000"

[http_service]
  internal_port = 8000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0
```

### Step 4: Deploy

```bash
cd components/typescript
fly launch
fly secrets set ASSEMBLYAI_API_KEY="your-key"
fly secrets set CARTESIA_API_KEY="your-key"
fly secrets set AWS_ACCESS_KEY_ID="your-key"
fly secrets set AWS_SECRET_ACCESS_KEY="your-key"
fly secrets set AWS_REGION="us-west-2"
fly deploy
```

### Cost
- **Free tier**: 3 shared CPUs + 3GB RAM
- **Paid**: $2-10/month

---

## Option 3: Traditional VPS (DigitalOcean/Linode)

If you prefer traditional hosting:

### Step 1: Create Droplet/Linode
- Choose Ubuntu 22.04
- At least 1GB RAM
- $6-10/month

### Step 2: SSH and Setup

```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install pnpm
npm install -g pnpm pm2

# Clone your repo
git clone https://github.com/KHemanthRaju/Voice-Sandwich-Agent.git
cd Voice-Sandwich-Agent/components/typescript

# Install dependencies
pnpm install

# Create .env file
cat > .env << EOF
ASSEMBLYAI_API_KEY="your-key"
CARTESIA_API_KEY="your-key"
AWS_ACCESS_KEY_ID="your-key"
AWS_SECRET_ACCESS_KEY="your-key"
AWS_REGION="us-west-2"
EOF

# Start with PM2
pm2 start pnpm --name voice-sandwich -- run server
pm2 save
pm2 startup
```

### Step 3: Configure Nginx (Optional)

```bash
sudo apt install nginx
sudo nano /etc/nginx/sites-available/voice-sandwich
```

Add:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

Enable and reload:
```bash
sudo ln -s /etc/nginx/sites-available/voice-sandwich /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## Frontend Deployment

For all options above, deploy the frontend to **AWS Amplify** or **Vercel**:

### AWS Amplify (Recommended)

1. Go to AWS Amplify Console
2. Connect your GitHub repo
3. Set build settings:
   - Build command: `cd components/web && pnpm install && pnpm build`
   - Output directory: `components/web/dist`
4. Add environment variable:
   - `VITE_WEBSOCKET_URL`: Your backend WebSocket URL
5. Deploy!

### Vercel (Alternative)

```bash
cd components/web
npx vercel
```

---

## Which Option Should You Choose?

### For Quick Testing
👉 **Railway** - Fastest and easiest

### For Production
👉 **Fly.io** - Better performance, global edge

### For Full Control
👉 **VPS** - Complete control, predictable costs

### For Enterprise
👉 **AWS Fargate** (see fargate-deployment.md)

---

## Monitoring

All platforms provide built-in logging:

**Railway:**
```bash
railway logs
```

**Fly.io:**
```bash
fly logs
```

**VPS:**
```bash
pm2 logs voice-sandwich
```

---

## Next Steps

1. Choose a platform above
2. Follow the deployment steps
3. Deploy your frontend to Amplify/Vercel
4. Update the WebSocket URL in your frontend
5. Test your voice agent!

🎉 You're done!
