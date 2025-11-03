# Installation Guide

Complete installation guide for n8n Telegram AI Bot with RAG and Context Memory.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Step 1: PostgreSQL Setup](#step-1-postgresql-setup)
- [Step 2: n8n Setup](#step-2-n8n-setup)
- [Step 3: Configure Credentials](#step-3-configure-credentials)
- [Step 4: Import Workflow](#step-4-import-workflow)
- [Step 5: Testing](#step-5-testing)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

- **n8n** v1.0 or higher
  - [Installation guide](https://docs.n8n.io/getting-started/installation/)
- **PostgreSQL** 14 or higher
  - [Download](https://www.postgresql.org/download/)
- **pgvector extension**
  - [GitHub](https://github.com/pgvector/pgvector)

### Required API Keys

- **OpenAI API Key**
  - Get from: https://platform.openai.com/api-keys
  - Requires credits for GPT-4 and DALL-E
- **Telegram Bot Token**
  - Create bot via: [@BotFather](https://t.me/botfather)

## Step 1: PostgreSQL Setup

### 1.1 Install PostgreSQL

**macOS:**
```bash
brew install postgresql@14
brew services start postgresql@14
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql-14
sudo systemctl start postgresql
```

**Windows:**
- Download installer from [postgresql.org](https://www.postgresql.org/download/windows/)

### 1.2 Install pgvector Extension

**macOS:**
```bash
brew install pgvector
```

**Ubuntu/Debian:**
```bash
sudo apt install postgresql-14-pgvector
```

**From source:**
```bash
git clone https://github.com/pgvector/pgvector.git
cd pgvector
make
sudo make install
```

### 1.3 Create Database

```bash
# Connect to PostgreSQL
psql postgres

# In psql console:
CREATE DATABASE telegram_bot;
\c telegram_bot

# Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgvector";

# Verify extensions
\dx
```

### 1.4 Run Database Schema

```bash
# Exit psql, then run:
psql -d telegram_bot -f database/schema.sql

# (Optional) Load sample data
psql -d telegram_bot -f database/seeds.sql
```

**Verify installation:**
```sql
\c telegram_bot
\dt  -- List tables (should show: users, conversations, documents, embeddings, user_sessions)
```

## Step 2: n8n Setup

### 2.1 Install n8n

**Using npm:**
```bash
npm install -g n8n
```

**Using Docker:**
```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

### 2.2 Start n8n

```bash
n8n start
```

Access n8n at: http://localhost:5678

## Step 3: Configure Credentials

### 3.1 PostgreSQL Credential

1. In n8n UI: **Credentials** → **New**
2. Select: **Postgres**
3. Fill in:
   - **Host**: `localhost` (or your server IP)
   - **Database**: `telegram_bot`
   - **User**: Your PostgreSQL username (default: `postgres`)
   - **Password**: Your PostgreSQL password
   - **Port**: `5432`
   - **SSL**: Disabled (for local development)
4. Click **Test** to verify connection
5. **Save** with name: `PostgreSQL account`

### 3.2 OpenAI Credential

1. In n8n: **Credentials** → **New**
2. Select: **OpenAI**
3. Fill in:
   - **API Key**: Your OpenAI API key
4. **Save** with name: `OpenAi account`

### 3.3 Telegram Credential

**Create Bot:**
1. Open Telegram and message [@BotFather](https://t.me/botfather)
2. Send: `/newbot`
3. Follow prompts to create bot
4. Copy the API token

**Add to n8n:**
1. In n8n: **Credentials** → **New**
2. Select: **Telegram**
3. Fill in:
   - **Access Token**: Your bot token from BotFather
4. **Save** with name: `Telegram bot`

## Step 4: Import Workflow

### 4.1 Import JSON

1. In n8n: **Workflows** → **Add Workflow** → **Import from File**
2. Select: `workflows/telegram-ai-bot.json`
3. Workflow imports with all nodes

### 4.2 Link Credentials

After import, verify each node has correct credentials:

**PostgreSQL nodes** (multiple):
- Get or Create User
- Load Conversation History
- Save User Message
- Search Knowledge Base
- Save Document
- Save Embedding
- Save Assistant Response

Click each → Select `PostgreSQL account`

**OpenAI nodes**:
- Generate Query Embedding
- Search Knowledge Base
- Chat_mode
- Greeting
- Create an Image
- Generate Doc Embedding

Click each → Select `OpenAi account`

**Telegram nodes**:
- Telegram Trigger
- Send Typing Action
- Text Reply
- Send Image
- Doc Added Confirmation
- Send Error Message

Click each → Select `Telegram bot`

### 4.3 Activate Workflow

1. Click **Activate** toggle (top right)
2. Workflow status changes to "Active"
3. Webhook automatically configured

**Verify webhook:**
```bash
curl https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getWebhookInfo
```

Should return n8n webhook URL.

## Step 5: Testing

### 5.1 Basic Test

Open Telegram and message your bot:
```
/start
```

Bot should respond with welcome message.

### 5.2 Test Context Memory

```
You: My name is John
Bot: [acknowledges]

You: What's my name?
Bot: [should remember "John"]
```

### 5.3 Test Image Generation

```
/image a sunset over mountains
```

Bot should generate and send image.

### 5.4 Test RAG (Knowledge Base)

```
/adddoc |Test| |This is test information| test
```

Then ask:
```
Tell me about the test
```

Bot should reference the added document.

### 5.5 Verify Database

```sql
-- Check user created
SELECT * FROM users;

-- Check conversations saved
SELECT * FROM conversations ORDER BY created_at DESC LIMIT 10;

-- Check documents
SELECT * FROM documents;
```

## Troubleshooting

### Bot Not Responding

**Check 1: Workflow Active?**
- In n8n, verify workflow toggle is ON

**Check 2: Webhook Configured?**
```bash
curl https://api.telegram.org/bot<TOKEN>/getWebhookInfo
```

Should show n8n URL. If not:
```bash
curl -X POST https://api.telegram.org/bot<TOKEN>/setWebhook \
  -d url=https://your-n8n-url.com/webhook/telegram
```

**Check 3: Credentials Valid?**
- Test each credential in n8n
- Verify API keys not expired

**Check 4: n8n Logs**
```bash
# Check n8n console output for errors
```

### pgvector Extension Error

```sql
-- Connect to database
\c telegram_bot

-- Create extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Verify
\dx vector
```

If still failing, reinstall pgvector.

### No RAG Results

**Check documents exist:**
```sql
SELECT COUNT(*) FROM documents WHERE is_active = true;
```

**Check embeddings exist:**
```sql
SELECT COUNT(*) FROM embeddings;
```

If no embeddings, you need to generate them:
- Add document via `/adddoc` command
- Or manually insert and generate embeddings

**Lower similarity threshold:**
In workflow, edit "Search Knowledge Base" node:
```sql
-- Change from 0.7 to 0.5
WHERE (1 - (e.embedding <=> '...'::vector)) > 0.5
```

### Context Not Loading

**Check conversations saved:**
```sql
SELECT COUNT(*) FROM conversations 
WHERE user_id = (SELECT id FROM users WHERE telegram_id = YOUR_TELEGRAM_ID);
```

If zero, send a message and check again.

**Check node execution:**
- In n8n, click workflow execution
- Verify "Load Conversation History" node executed successfully

### High Latency

**Optimization tips:**
1. Use GPT-3.5-turbo instead of GPT-4 (in "Chat_mode" node)
2. Reduce context window (in "Format Conversation Context")
3. Lower RAG result limit (in "Search Knowledge Base")
4. Add database indexes:
```sql
CREATE INDEX IF NOT EXISTS idx_conv_user_created 
ON conversations(user_id, created_at DESC);
```

## Next Steps

After successful installation:

1. ✅ Customize bot personality ([CONFIGURATION.md](CONFIGURATION.md))
2. ✅ Add documents to knowledge base
3. ✅ Set up monitoring and backups
4. ✅ Review [database/maintenance.sql](../database/maintenance.sql) for useful queries

## Support

- 📖 [Configuration Guide](CONFIGURATION.md)
- 🐛 [Report Issues](https://github.com/gendonholaholo/n8n-telegram-aiBot/issues)
- 💬 [Discussions](https://github.com/gendonholaholo/n8n-telegram-aiBot/discussions)

---

**Installation complete! Your bot is ready to use.** 🎉
