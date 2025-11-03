-- ============================================
-- Maintenance & Analytics Queries
-- n8n Telegram AI Bot
-- ============================================

-- ============================================
-- 1. USER ANALYTICS
-- ============================================

-- Get total users
SELECT
    COUNT(*) as total_users,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_users
FROM users;

-- Get top 10 most active users
SELECT
    u.telegram_id,
    u.first_name,
    u.username,
    COUNT(c.id) as message_count,
    MAX(c.created_at) as last_message,
    MIN(c.created_at) as first_message
FROM users u
JOIN conversations c ON u.id = c.user_id
GROUP BY u.id
ORDER BY message_count DESC
LIMIT 10;

-- Get daily message statistics (last 30 days)
SELECT
    DATE(created_at) as date,
    COUNT(*) as total_messages,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(CASE WHEN message_role = 'user' THEN 1 END) as user_messages,
    COUNT(CASE WHEN message_role = 'assistant' THEN 1 END) as bot_messages
FROM conversations
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Find inactive users (no activity in last 30 days)
SELECT
    u.telegram_id,
    u.first_name,
    u.username,
    MAX(c.created_at) as last_activity,
    NOW() - MAX(c.created_at) as days_inactive
FROM users u
JOIN conversations c ON u.id = c.user_id
GROUP BY u.id
HAVING MAX(c.created_at) < NOW() - INTERVAL '30 days'
ORDER BY last_activity DESC;

-- ============================================
-- 2. CONVERSATION ANALYTICS
-- ============================================

-- Get full conversation for a user (replace telegram_id)
SELECT
    c.message_role,
    c.message_content,
    c.created_at,
    c.model_used,
    c.token_count
FROM conversations c
JOIN users u ON c.user_id = u.id
WHERE u.telegram_id = 123456789  -- Replace with actual telegram_id
ORDER BY c.created_at DESC
LIMIT 50;

-- Find conversations with specific keywords
SELECT
    u.telegram_id,
    u.first_name,
    c.message_role,
    c.message_content,
    c.created_at
FROM conversations c
JOIN users u ON c.user_id = u.id
WHERE c.message_content ILIKE '%keyword%'  -- Replace with your search term
ORDER BY c.created_at DESC
LIMIT 50;

-- Model usage statistics
SELECT
    model_used,
    COUNT(*) as usage_count,
    AVG(token_count) as avg_tokens,
    MAX(token_count) as max_tokens,
    MIN(token_count) as min_tokens
FROM conversations
WHERE model_used IS NOT NULL
  AND message_role = 'assistant'
GROUP BY model_used
ORDER BY usage_count DESC;

-- ============================================
-- 3. KNOWLEDGE BASE MANAGEMENT
-- ============================================

-- Get knowledge base statistics
SELECT
    category,
    COUNT(*) as document_count,
    SUM(LENGTH(content)) as total_content_length,
    AVG(LENGTH(content)) as avg_content_length
FROM documents
WHERE is_active = true
GROUP BY category
ORDER BY document_count DESC;

-- Search documents by content
SELECT
    id,
    title,
    category,
    LEFT(content, 100) as preview,
    LENGTH(content) as content_length,
    created_at
FROM documents
WHERE content ILIKE '%search term%'  -- Replace with your search
  AND is_active = true
ORDER BY created_at DESC;

-- Get documents without embeddings
SELECT
    d.id,
    d.title,
    d.category,
    d.created_at
FROM documents d
LEFT JOIN embeddings e ON d.id = e.document_id
WHERE e.id IS NULL
  AND d.is_active = true;

-- ============================================
-- 4. MAINTENANCE OPERATIONS
-- ============================================

-- Analyze table statistics
ANALYZE users;
ANALYZE conversations;
ANALYZE documents;
ANALYZE embeddings;

-- Vacuum tables (clean up dead rows)
VACUUM ANALYZE users;
VACUUM ANALYZE conversations;
VACUUM ANALYZE documents;
VACUUM ANALYZE embeddings;

-- Check table sizes
SELECT
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check index usage
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- ============================================
-- 5. DATA CLEANUP
-- ============================================

-- Archive old conversations (soft delete)
-- First add archived column if not exists
-- ALTER TABLE conversations ADD COLUMN IF NOT EXISTS archived BOOLEAN DEFAULT FALSE;

UPDATE conversations
SET archived = true
WHERE created_at < NOW() - INTERVAL '90 days'
  AND archived = false;

-- Deactivate old unused documents
UPDATE documents
SET is_active = false
WHERE updated_at < NOW() - INTERVAL '180 days'
  AND is_active = true
  AND source = 'user';

-- ============================================
-- 6. PERFORMANCE MONITORING
-- ============================================

-- Check database connections
SELECT
    datname,
    count(*) as connections
FROM pg_stat_activity
WHERE datname = 'telegram_bot'
GROUP BY datname;

-- Check long-running queries
SELECT
    pid,
    now() - query_start as duration,
    state,
    query
FROM pg_stat_activity
WHERE state != 'idle'
  AND now() - query_start > interval '1 minute'
ORDER BY duration DESC;

-- ============================================
-- 7. TESTING QUERIES
-- ============================================

-- Test vector similarity search (requires existing embeddings)
-- Replace the vector with an actual embedding from your data
SELECT
    chunk_text,
    1 - (embedding <=> (SELECT embedding FROM embeddings LIMIT 1)) as similarity
FROM embeddings
ORDER BY similarity DESC
LIMIT 5;

-- Verify RAG functionality
SELECT
    e.chunk_text,
    d.title,
    d.category,
    1 - (e.embedding <=> (SELECT embedding FROM embeddings LIMIT 1)) as similarity
FROM embeddings e
JOIN documents d ON e.document_id = d.id
WHERE d.is_active = true
ORDER BY similarity DESC
LIMIT 5;

-- ============================================
-- 8. BACKUP OPERATIONS
-- ============================================

-- Create backup table for conversations
CREATE TABLE IF NOT EXISTS conversations_backup AS
SELECT * FROM conversations
WHERE created_at >= NOW() - INTERVAL '90 days';

-- Note: For full database backup, use pg_dump:
-- pg_dump telegram_bot > backup_$(date +%Y%m%d).sql

-- ============================================
-- 9. USER PREFERENCES MANAGEMENT
-- ============================================

-- Update user language preference
UPDATE users
SET preferences = jsonb_set(
    COALESCE(preferences, '{}'::jsonb),
    '{language}',
    '"en"'::jsonb
)
WHERE telegram_id = 123456789;  -- Replace with actual telegram_id

-- Get users with specific preferences
SELECT
    telegram_id,
    first_name,
    preferences
FROM users
WHERE preferences IS NOT NULL
  AND preferences != '{}'::jsonb;

-- ============================================
-- END OF MAINTENANCE QUERIES
-- ============================================
