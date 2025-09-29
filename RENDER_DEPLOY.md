# Deploy All MCPs to Render

## Step 1: Push to GitHub
```bash
cd /Users/vihari/Desktop/browzy/klavis
git add .
git commit -m "Add Render deployment config for all 50+ MCPs"
git push origin main
```

## Step 2: Deploy to Render
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New"** → **"Blueprint"**
3. Connect your GitHub account if not already connected
4. Select repository: `VihariKanukollu/klavis`
5. Blueprint file path: `render.yaml` (in repo root)
6. Click **"Apply Blueprint"**

Render will:
- Create 1 public web service (mcp-proxy)
- Create 50+ private services (one per MCP)
- Build all containers automatically
- Give you a public URL like `mcp-proxy-xxxxx.onrender.com`

## Step 3: Configure DNS in Cloudflare
1. Copy the public URL from Render dashboard
2. In Cloudflare DNS for `browzy.ai`:
   - **Delete** the current "@ → mcp.browzy.ai" record
   - **Add new CNAME**: 
     - Type: `CNAME`
     - Name: `mcp`
     - Target: `mcp-proxy-xxxxx.onrender.com` (your Render URL)
     - Proxy: **Enabled** (orange cloud)

## Step 4: Test
Wait 2-3 minutes for DNS propagation, then test:
```bash
curl https://mcp.browzy.ai/hacker_news/mcp/
```

Should return MCP protocol response.

## Step 5: Update Onyx Hub
Once DNS works:
1. Replace `servers.json` with `servers_remote.json` in your Onyx MCP Hub
2. Set `NEXT_PUBLIC_MCP_REMOTE_BASE=https://mcp.browzy.ai` in Onyx web
3. Remove local MCP containers from Onyx compose

## Notes
- **Plan**: Render Starter plan should handle this load initially
- **Scaling**: Upgrade individual services if needed
- **Monitoring**: Render provides logs/metrics for each service
- **Cost**: ~$7/month per service, but you can disable unused MCPs in `servers_remote.json`
