# Configuration Guide

Advanced configuration options for n8n Telegram AI Bot.

## Table of Contents

- [Bot Personality](#bot-personality)
- [Context Window](#context-window)
- [RAG Configuration](#rag-configuration)
- [Token Limits](#token-limits)
- [Model Selection](#model-selection)
- [Advanced Features](#advanced-features)

## Bot Personality

### Customize Bot Character

Edit the **Settings** node in n8n workflow:

```javascript
{
  "name": "system_command",
  "value": "Kamu adalah Elisabeth, AI assistant yang ramah dan membantu..."
}
```

**Example personalities:**

**Professional Assistant:**
```javascript
"You are a professional AI assistant. You provide accurate, concise responses in a formal tone. You excel at problem-solving and technical explanations."
```

**Friendly Chatbot:**
```javascript
"You are a friendly, casual AI assistant. You use conversational language and emojis. You're helpful but also fun to talk to!"
```

**Expert Consultant:**
```javascript
"You are an expert consultant with deep knowledge in technology and business. You provide strategic insights and data-driven recommendations."
```

### Multi-language Support

The bot automatically detects user language from Telegram profile.

**Custom language handling:**
```javascript
// In Settings node
"Respond in {{ $json.language_code === 'id' ? 'Indonesian' : 'English' }}. ..."
```

## Context Window

### Adjust Memory Size


Edit the **Format Conversation Context** node:

```javascript
// Default: Last 10 messages
if (conversationHistory.length > 10) {
  conversationHistory = conversationHistory.slice(-10);
}

// Increase to 20 messages
if (conversationHistory.length > 20) {
  conversationHistory = conversationHistory.slice(-20);
}

// Reduce to 5 messages (faster, cheaper)
if (conversationHistory.length > 5) {
  conversationHistory = conversationHistory.slice(-5);
}
```

**Trade-offs:**

| Window Size | Pros | Cons |
|-------------|------|------|
| 5 messages | Fast, cheap | Limited context |
| 10 messages | Balanced | Default |
| 20 messages | Rich context | Slower, expensive |

## RAG Configuration

### Similarity Threshold

Edit the **Search Knowledge Base (RAG)** node:

```sql
-- Default: 0.7 (strict matching)
WHERE (1 - (e.embedding <=> '{{ $json.embedding }}'::vector)) > 0.7

-- Relaxed: 0.5 (more results)
WHERE (1 - (e.embedding <=> '{{ $json.embedding }}'::vector)) > 0.5

-- Strict: 0.8 (only highly relevant)
WHERE (1 - (e.embedding <=> '{{ $json.embedding }}'::vector)) > 0.8
```

**Threshold guide:**
- `0.9+`: Nearly identical matches
- `0.7-0.8`: Highly relevant
- `0.5-0.7`: Somewhat relevant
- `< 0.5`: May be off-topic

### Number of RAG Results

```sql
-- Default: 5 results
ORDER BY e.embedding <=> '{{ $json.embedding }}'::vector
LIMIT 5;

-- More context: 10 results
LIMIT 10;

-- Faster: 3 results
LIMIT 3;
```

### Document Categories

Filter by category:

```sql
WHERE d.is_active = true
  AND d.category = 'tutorial'  -- Only tutorials
  AND (1 - (e.embedding <=> '...'::vector)) > 0.7
```

Or multiple categories:

```sql
WHERE d.is_active = true
  AND d.category IN ('tutorial', 'help', 'faq')
  AND (1 - (e.embedding <=> '...'::vector)) > 0.7
```

## Token Limits

### Response Length

Edit the **Settings** node:

```javascript
{
  "name": "token_length",
  "value": 800  // Default: ~600-800 words
}
```

**Token recommendations:**

| Use Case | Tokens | Typical Length |
|----------|--------|---------------|
| Brief answers | 200-400 | 1-2 paragraphs |
| Standard (default) | 600-800 | 3-5 paragraphs |
| Detailed responses | 1000-1500 | Long form |
| Maximum | 4000 | Full articles |

**Cost consideration:**
- Higher tokens = higher costs
- Balance detail vs. cost
- Monitor OpenAI usage dashboard

### Temperature Setting

Controls creativity vs. consistency:

```javascript
{
  "name": "model_temperature",
  "value": 0.8  // Default
}
```

**Temperature guide:**
- `0.0-0.3`: Focused, deterministic, factual
- `0.4-0.7`: Balanced
- `0.8-1.0`: Creative, varied responses
- `1.0+`: Very creative, unpredictable

## Model Selection

### Chat Models

Edit the **Chat_mode** node:

```javascript
{
  "model": "gpt-4"  // Default
}
```

**Available models:**

| Model | Pros | Cons | Cost |
|-------|------|------|------|
| `gpt-4` | Highest quality | Expensive, slower | 💰💰💰 |
| `gpt-4-turbo` | Fast + quality | Expensive | 💰💰 |
| `gpt-3.5-turbo` | Fast, cheap | Lower quality | 💰 |

**When to use:**
- **gpt-4**: Complex reasoning, important queries
- **gpt-3.5-turbo**: Simple chat, high volume

### Image Models

Edit the **Create an Image** node:

```javascript
{
  "options": {
    "size": "512x512"  // Default
  }
}
```

**Available sizes:**
- `256x256`: Fastest, cheapest
- `512x512`: Balanced (default)
- `1024x1024`: High quality, expensive

### Embedding Models

Currently using: `text-embedding-ada-002`

**Alternative:**
- `text-embedding-3-small`: Cheaper, faster
- `text-embedding-3-large`: Higher quality

Change in both:
- **Generate Query Embedding** node
- **Generate Doc Embedding** node

## Advanced Features

### Rate Limiting

Add a new **Code** node before **Chat_mode**:

```javascript
// Get user ID
const userId = $('Settings').item.json.user_id;
const oneMinuteAgo = new Date(Date.now() - 60000).toISOString();

// Check message count (requires PostgreSQL query)
// If > 10 messages per minute, throw error

if (messageCount > 10) {
  throw new Error('Rate limit exceeded. Please wait a moment.');
}

return { json: $json };
```

### User Preferences

Store custom preferences:

```sql
-- Update user preferences
UPDATE users
SET preferences = jsonb_set(
  COALESCE(preferences, '{}'::jsonb),
  '{response_style}',
  '"detailed"'::jsonb
)
WHERE telegram_id = {{ $json.telegram_id }};
```

Use in workflow:

```javascript
// In Settings node
const prefs = $('Get or Create User').item.json.preferences;
const style = prefs.response_style || 'standard';

// Adjust system prompt based on preference
```

### Context Summarization

For very long conversations, summarize old messages:

```javascript
// In Format Conversation Context
if (conversationHistory.length > 20) {
  // Keep last 10 messages
  const recent = conversationHistory.slice(-10);
  
  // Summarize older messages (requires OpenAI call)
  const oldMessages = conversationHistory.slice(0, -10);
  const summary = await summarizeMessages(oldMessages);
  
  // Use summary + recent messages
  conversationHistory = [
    { role: 'system', content: 'Previous conversation summary: ' + summary },
    ...recent
  ];
}
```

### Document Chunking

For large documents, split into chunks:

```javascript
// When adding documents
function chunkText(text, maxChunkSize = 500) {
  const words = text.split(' ');
  const chunks = [];
  
  for (let i = 0; i < words.length; i += maxChunkSize) {
    chunks.push(words.slice(i, i + maxChunkSize).join(' '));
  }
  
  return chunks;
}

// Insert each chunk with its own embedding
chunks.forEach((chunk, index) => {
  // Insert into embeddings table with chunk_index = index
});
```

### Custom Commands

Add new commands in the **CheckCommand** switch node:

```javascript
{
  "output": 5,  // New output
  "value2": "/help",
  "operation": "startsWith"
}
```

Then create a new path with appropriate response.

### Webhook Customization

For advanced webhook handling, modify the **Telegram Trigger** node:

```javascript
{
  "updates": ["message", "edited_message", "callback_query"]
}
```

Handle different update types with switch nodes.

## Performance Optimization

### Database Indexes

Add these indexes for better performance:

```sql
-- Improve conversation queries
CREATE INDEX IF NOT EXISTS idx_conv_user_recent 
ON conversations(user_id, created_at DESC) 
WHERE created_at > NOW() - INTERVAL '7 days';

-- Improve RAG searches
CREATE INDEX IF NOT EXISTS idx_emb_active_docs 
ON embeddings(document_id) 
WHERE document_id IN (SELECT id FROM documents WHERE is_active = true);
```

### Caching

Implement response caching for common queries:

1. Create `response_cache` table
2. Store query hash + response
3. Check cache before calling OpenAI
4. Set TTL for cache entries

### Batch Processing

For bulk operations:

```sql
-- Insert multiple documents at once
INSERT INTO documents (title, content, category, source) VALUES
  ('Doc 1', 'Content 1', 'cat1', 'bulk'),
  ('Doc 2', 'Content 2', 'cat2', 'bulk'),
  ('Doc 3', 'Content 3', 'cat3', 'bulk');
```

## Monitoring

### Track Usage

```sql
-- Daily message count
SELECT 
  DATE(created_at), 
  COUNT(*) 
FROM conversations 
GROUP BY DATE(created_at);

-- Token usage by model
SELECT 
  model_used, 
  SUM(token_count) as total_tokens
FROM conversations 
WHERE message_role = 'assistant'
GROUP BY model_used;
```

### Error Tracking

Add error logging:

```javascript
// In error handling nodes
try {
  // Main logic
} catch (error) {
  // Log to database or external service
  console.error('Error:', error);
  
  // Send admin notification
}
```

## Security

### Sanitize Inputs

Prevent SQL injection:

```javascript
// Escape special characters
const sanitized = input.replace(/'/g, "''");
```

### API Key Management

- Never commit API keys
- Use environment variables
- Rotate keys regularly
- Monitor usage for anomalies

### User Blacklist

```sql
-- Create blacklist table
CREATE TABLE user_blacklist (
  telegram_id BIGINT PRIMARY KEY,
  reason TEXT,
  blacklisted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Check in workflow
SELECT * FROM user_blacklist WHERE telegram_id = {{ $json.telegram_id }};
```

## Backup Strategy

### Database Backups

```bash
# Daily backup
pg_dump telegram_bot > backup_$(date +%Y%m%d).sql

# Automated with cron
0 2 * * * pg_dump telegram_bot > /backups/telegram_bot_$(date +\%Y\%m\%d).sql
```

### Workflow Backups

Export workflow JSON regularly:
1. In n8n: Workflow → Download
2. Version control with git
3. Keep multiple versions

## Testing Configuration Changes

Before deploying changes:

1. **Export current workflow** (backup)
2. **Duplicate workflow** for testing
3. **Test with test account**
4. **Monitor performance**
5. **Deploy to production**

## Support

For questions about configuration:
- 📖 [Installation Guide](INSTALLATION.md)
- 🐛 [Report Issues](https://github.com/gendonholaholo/n8n-telegram-aiBot/issues)
- 💬 [Discussions](https://github.com/gendonholaholo/n8n-telegram-aiBot/discussions)

---

**Configuration complete!** Customize your bot to fit your needs. 🎯
