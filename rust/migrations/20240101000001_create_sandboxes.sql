-- Create sandboxes table
CREATE TABLE IF NOT EXISTS sandboxes (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    html TEXT,
    mint_version VARCHAR(50) NOT NULL DEFAULT '0.19.0',
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sandboxes_user_id ON sandboxes(user_id);
CREATE INDEX IF NOT EXISTS idx_sandboxes_updated_at ON sandboxes(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_sandboxes_title ON sandboxes(title);
