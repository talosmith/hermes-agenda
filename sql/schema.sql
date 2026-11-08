-- hermes-agenda · Postgres schema
-- Run once against the database used by the "Postgres Automação" credential in n8n.

-- Conversation memory for the AI agent (n8n Postgres Chat Memory node).
-- n8n creates this table on its own; we create it first so it carries a timestamp
-- that the nightly cleanup job (workflow 03) uses for data retention.
CREATE TABLE IF NOT EXISTS n8n_chat_histories (
    id          SERIAL PRIMARY KEY,
    session_id  VARCHAR(255) NOT NULL,
    message     JSONB        NOT NULL,
    criado_em   TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_chat_session ON n8n_chat_histories (session_id);

-- Contacts for whom the bot is paused (human takeover, crisis, manual #pausar).
CREATE TABLE IF NOT EXISTS bot_pausa (
    telefone  TEXT PRIMARY KEY,
    ate       TIMESTAMPTZ NOT NULL,
    motivo    TEXT
);

-- Idempotency log: guarantees each reminder (24h / 2h) is sent only once per session.
CREATE TABLE IF NOT EXISTS lembretes_enviados (
    event_id    TEXT        NOT NULL,
    tipo        TEXT        NOT NULL,          -- '24h' | '2h'
    inicio      TIMESTAMPTZ NOT NULL,
    telefone    TEXT        NOT NULL,
    mensagem    TEXT        NOT NULL,
    enviado_em  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (event_id, tipo, inicio)
);
