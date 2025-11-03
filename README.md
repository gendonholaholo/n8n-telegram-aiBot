# n8n Telegram AI Bot with RAG & Context Memory

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![n8n](https://img.shields.io/badge/n8n-workflow-FF6D5A)](https://n8n.io)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-336791)](https://www.postgresql.org)
[![OpenAI](https://img.shields.io/badge/OpenAI-GPT--4-412991)](https://openai.com)

An intelligent Telegram bot built with n8n featuring **RAG (Retrieval Augmented Generation)** and **conversation memory**. The bot can chat naturally, generate images, remember context, and search through a knowledge base to provide accurate responses.

## Features

### Core Capabilities
- **Natural Conversations** - Context-aware chat with 10-message memory window
- **RAG Technology** - Semantic search through knowledge base using vector embeddings
- **Image Generation** - DALL-E powered image creation
- **Dynamic Knowledge Base** - Add documents on-the-fly via Telegram commands
- **PostgreSQL Storage** - Persistent data with pgvector for semantic search
- **Multi-language** - Supports Indonesian and English

### Technical Features
- Vector similarity search with pgvector
- OpenAI embeddings (text-embedding-ada-002)
- Automatic user management
- Conversation history tracking
- Efficient context window management

## Quick Start

### Prerequisites
- [n8n](https://n8n.io) v1.0+
- [PostgreSQL](https://www.postgresql.org) 14+ with [pgvector](https://github.com/pgvector/pgvector)
- [OpenAI API Key](https://platform.openai.com/api-keys)
- [Telegram Bot Token](https://t.me/botfather)

### Installation

1. **Setup Database**
```bash
# Create database
createdb telegram_bot

# Run schema setup
psql -d telegram_bot -f database/schema.sql

# (Optional) Load sample data
psql -d telegram_bot -f database/seeds.sql
```

2. **Configure n8n Credentials**
   - **PostgreSQL**: Database connection
   - **OpenAI**: API key
   - **Telegram**: Bot token from @BotFather

3. **Import Workflow**
```bash
# In n8n UI: Workflows → Import from File
# Select: workflows/telegram-ai-bot.json
```

4. **Activate Workflow**
   - Open workflow in n8n
   - Verify all credentials are linked
   - Click "Activate" toggle

5. **Test Bot**
```
Send to your bot: /start
```

## Usage

### User Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/start` | Welcome message | `/start` |
| `/image [prompt]` | Generate image | `/image sunset over mountains` |
| `/adddoc` | Add knowledge | `/adddoc \|Title\| \|Content\| category` |
| `[text]` | Chat with AI | `Tell me about RAG` |

### Examples

**Natural Chat**
```
User: What can you do?
Bot: [Responds using context + knowledge base]
```

**Image Generation**
```
User: /image a cute cat in Studio Ghibli style
Bot: [Generates and sends image]
```

**Add Knowledge**
```
User: /adddoc |Bot Info| |I can chat, generate images, and remember conversations| tutorial
Bot: Document added successfully!
```

## Architecture

```
Telegram User
     ↓
┌────────────────────────────────────────┐
│         n8n Workflow                   │
│  ┌──────────────────────────────────┐  │
│  │  1. User Management (PostgreSQL) │  │
│  └──────────────────────────────────┘  │
│  ┌──────────────────────────────────┐  │
│  │  2. Load Conversation History    │  │
│  │     (Last 10 messages)           │  │
│  └──────────────────────────────────┘  │
│  ┌──────────────────────────────────┐  │
│  │  3. Generate Query Embedding     │  │
│  │     (OpenAI text-embedding)      │  │
│  └──────────────────────────────────┘  │
│  ┌──────────────────────────────────┐  │
│  │  4. Vector Similarity Search     │  │
│  │     (pgvector - RAG)             │  │
│  └──────────────────────────────────┘  │
│  ┌──────────────────────────────────┐  │
│  │  5. Merge Context + RAG Results  │  │
│  └──────────────────────────────────┘  │
│  ┌──────────────────────────────────┐  │
│  │  6. Generate Response (GPT-4)    │  │
│  └──────────────────────────────────┘  │
│  ┌──────────────────────────────────┐  │
│  │  7. Save to Database             │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
     ↓
Telegram User (Response)
```

## Database Schema

- **users** - User profiles and preferences
- **conversations** - Chat history with roles (user/assistant)
- **documents** - Knowledge base articles
- **embeddings** - Vector embeddings for semantic search

See [database/schema.sql](database/schema.sql) for full schema.

## Configuration

### Customize Bot Personality

Edit the "Settings" node in n8n workflow:
```javascript
"Kamu adalah Elisabeth, AI assistant yang ramah..."
```

### Adjust Context Window

In "Format Conversation Context" node:
```javascript
if (conversationHistory.length > 10) {
  conversationHistory = conversationHistory.slice(-10);
}
```

### Modify RAG Threshold

In "Search Knowledge Base" node:
```sql
WHERE (1 - (e.embedding <=> '...'::vector)) > 0.7  -- Similarity threshold
```

## Analytics

Run queries from `database/maintenance.sql`:

```sql
-- Top active users
SELECT u.first_name, COUNT(c.id) as messages
FROM users u
JOIN conversations c ON u.id = c.user_id
GROUP BY u.id
ORDER BY messages DESC
LIMIT 10;

-- Daily statistics
SELECT DATE(created_at), COUNT(*) as messages
FROM conversations
GROUP BY DATE(created_at)
ORDER BY DATE(created_at) DESC;
```

## Testing

### Test Conversation Memory
```
1. Send: "My name is John"
2. Send: "What's my name?"
3. Bot should remember "John"
```

### Test RAG
```
1. Add document: /adddoc |Test| |This is test info| test
2. Ask: "Tell me about the test"
3. Bot should reference the added document
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Bot not responding | Check workflow activation, webhook config, credentials |
| No RAG results | Lower similarity threshold, verify embeddings exist |
| Context not loading | Check conversations table, verify user_id |
| pgvector error | Install extension: `CREATE EXTENSION vector;` |

See [docs/INSTALLATION.md](docs/INSTALLATION.md) for detailed troubleshooting.

## Documentation

- [Installation Guide](docs/INSTALLATION.md) - Detailed setup instructions
- [Configuration Guide](docs/CONFIGURATION.md) - Advanced configuration options
- [Database Schema](database/schema.sql) - Complete database structure
- [Maintenance Queries](database/maintenance.sql) - Useful SQL queries

## Project Structure

```
.
├── README.md                  # This file
├── workflows/
│   └── telegram-ai-bot.json  # n8n workflow
├── database/
│   ├── schema.sql            # Database schema
│   ├── seeds.sql             # Sample data
│   └── maintenance.sql       # Helper queries
└── docs/
    ├── INSTALLATION.md       # Detailed installation
    └── CONFIGURATION.md      # Configuration guide
```

## Roadmap

- [ ] Multi-user conversation threads
- [ ] Voice message support
- [ ] Document chunking for long texts
- [ ] Automatic context summarization
- [ ] Admin dashboard with analytics
- [ ] Rate limiting per user
- [ ] Custom commands support

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [n8n](https://n8n.io) - Workflow automation platform
- [OpenAI](https://openai.com) - GPT-4 and DALL-E
- [pgvector](https://github.com/pgvector/pgvector) - Vector similarity search
- [PostgreSQL](https://www.postgresql.org) - Database

## Support

- [Documentation](docs/INSTALLATION.md)
- [Issue Tracker](https://github.com/gendonholaholo/n8n-telegram-aiBot/issues)
- [Discussions](https://github.com/gendonholaholo/n8n-telegram-aiBot/discussions)

## Links

- **Demo Bot**: Contact [@your_bot_username](https://t.me/your_bot_username)
- **Author**: [@gendonholaholo](https://github.com/gendonholaholo)

---

**Made with care using n8n, PostgreSQL, and OpenAI**
