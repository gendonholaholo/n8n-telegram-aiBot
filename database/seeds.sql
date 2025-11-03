-- ============================================
-- Sample Data (Seeds)
-- n8n Telegram AI Bot
-- ============================================

-- Insert sample documents for knowledge base
INSERT INTO documents (title, content, category, source) VALUES
(
    'Bot Introduction',
    'This is Elisabeth, an AI assistant that speaks Indonesian fluently. Elisabeth is friendly and helpful, designed to assist users with various tasks including natural conversations, image generation, and information retrieval.',
    'about',
    'system'
),
(
    'Bot Capabilities',
    'Elisabeth can: 1) Chat naturally in Indonesian and English with context memory, 2) Generate images using DALL-E with /image command, 3) Remember conversation context for personalized responses, 4) Search knowledge base to provide accurate information using RAG technology.',
    'capabilities',
    'system'
),
(
    'Image Generation Guide',
    'To generate images, use the /image command followed by your description. Example: /image a cute kitten with big eyes in Miyazaki Studio Ghibli style. The bot will create a 512x512 image based on your prompt using DALL-E. Be specific with your descriptions for better results.',
    'help',
    'system'
),
(
    'Context Memory Feature',
    'Bot ini memiliki kemampuan mengingat percakapan sebelumnya. Setiap pesan yang Anda kirim dan respon dari bot akan tersimpan di database. Bot dapat mengingat hingga 10 pesan terakhir untuk memberikan respon yang lebih contextual dan personal.',
    'features',
    'system'
),
(
    'RAG Technology',
    'Bot menggunakan RAG (Retrieval Augmented Generation) yang memungkinkan bot untuk mencari informasi relevan dari knowledge base sebelum memberikan jawaban. Teknologi ini menggunakan vector embeddings dan similarity search untuk menemukan dokumen yang paling relevan dengan pertanyaan Anda.',
    'technology',
    'system'
),
(
    'Available Commands',
    'Command yang tersedia: 1) /start untuk welcome message, 2) /image [deskripsi] untuk generate gambar, 3) /adddoc |Title| |Content| [Category] untuk menambah dokumen ke knowledge base, 4) Atau kirim text biasa untuk chat dengan AI yang akan menggunakan context memory dan RAG.',
    'help',
    'system'
);

-- ============================================
-- Note: Embeddings must be generated separately
-- ============================================
-- After inserting documents, you need to:
-- 1. Generate embeddings using OpenAI API (text-embedding-ada-002)
-- 2. Insert embeddings into the embeddings table
-- This is typically done through the n8n workflow or a separate script
--
-- Example (after getting embedding from OpenAI):
-- INSERT INTO embeddings (document_id, chunk_text, chunk_index, embedding)
-- SELECT id, content, 0, '[0.1, 0.2, ...]'::vector
-- FROM documents WHERE title = 'Bot Introduction';

-- ============================================
-- Verification
-- ============================================
DO $$
DECLARE
    doc_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO doc_count FROM documents;
    RAISE NOTICE 'Sample data loaded successfully!';
    RAISE NOTICE 'Documents inserted: %', doc_count;
    RAISE NOTICE 'Remember to generate embeddings for RAG functionality!';
END $$;
