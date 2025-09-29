# Deploy All 50+ MCPs on Render for $7/month

This guide shows how to deploy all Klavis MCP servers in a single container, saving you from paying $350+/month.

## Prerequisites
- Render account
- GitHub fork of klavis repo (you have this)
- Domain on Cloudflare (you have mcp.browzy.ai)

## Step 1: Push the new files to your fork

```bash
cd /Users/vihari/Desktop/browzy/klavis
git add supervisord.conf nginx-internal.conf multi-mcp.Dockerfile render-single-container.yaml
git commit -m "Add single-container setup for all MCPs"
git push origin main
```

## Step 2: Deploy on Render

1. Go to https://dashboard.render.com/
2. Click "New +" → "Blueprint"
3. Connect your GitHub repository: `VihariKanukollu/klavis`
4. Select `render-single-container.yaml` as the blueprint file
5. Click "Create Blueprint Instance"

This will create ONE service called `mcp-all-in-one` that runs all 50+ MCP servers.

## Step 3: Configure Cloudflare DNS

1. Go to Cloudflare Dashboard
2. Select your domain (browzy.ai)
3. Go to DNS settings
4. Add a CNAME record:
   - Name: `mcp`
   - Target: `[your-render-service].onrender.com` (get this from Render dashboard)
   - Proxy status: Proxied (orange cloud)
   - TTL: Auto

## Step 4: Update Onyx MCP Hub Configuration

Once deployed, update your `servers_remote.json` in Onyx to point to the live URLs, then restart the MCP Hub:

```bash
docker compose -f onyx/deployment/docker_compose/docker-compose.yml restart mcp_hub
```

## How It Works

1. **Single Container**: All MCPs run in one container managed by supervisord
2. **Internal Routing**: Nginx routes requests to different internal ports (5001-5058)
3. **Cost**: Just $7/month for Render's starter plan
4. **URLs**: Each MCP is accessible at `https://mcp.browzy.ai/<slug>/mcp/`

## Monitoring

- View logs in Render dashboard
- Each MCP has its own log file inside the container
- Health check endpoint: `https://mcp.browzy.ai/healthz`

## Troubleshooting

If an individual MCP crashes:
- Supervisord will automatically restart it
- Check logs: `/var/log/<mcp-name>.err.log`
- The other MCPs continue running unaffected

## Cost Breakdown

- Traditional approach: 50+ services × $7 = $350+/month
- This approach: 1 service × $7 = $7/month
- Savings: $343+/month (98% cost reduction!)
