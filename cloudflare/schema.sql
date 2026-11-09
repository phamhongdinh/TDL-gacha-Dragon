-- Schema Cloudflare D1 (SQLite) cho TDL-gacha-Dragon
CREATE TABLE IF NOT EXISTS users (
    username TEXT PRIMARY KEY,
    password TEXT NOT NULL DEFAULT '123',
    save_json TEXT NOT NULL DEFAULT '{}',
    updated_at INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS world_boss (
    id TEXT PRIMARY KEY,
    level INTEGER NOT NULL DEFAULT 1,
    max_hp INTEGER NOT NULL DEFAULT 18000,
    hp INTEGER NOT NULL DEFAULT 18000,
    participants_json TEXT NOT NULL DEFAULT '[]',
    logs_json TEXT NOT NULL DEFAULT '[]',
    updated_at INTEGER NOT NULL DEFAULT 0
);
