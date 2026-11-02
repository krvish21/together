-- PostgreSQL schema for Together App

CREATE TABLE IF NOT EXISTS couples (
  id VARCHAR(64) PRIMARY KEY,
  space_code VARCHAR(16) UNIQUE NOT NULL,
  partner1_name VARCHAR(100) NOT NULL,
  partner2_name VARCHAR(100),
  anniversary_date VARCHAR(32),
  avatar_p1 VARCHAR(255),
  avatar_p2 VARCHAR(255),
  relationship_status VARCHAR(64) DEFAULT 'In Love ❤️',
  theme_color VARCHAR(32) DEFAULT '#FF6584',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_couples_space_code ON couples(space_code);

CREATE TABLE IF NOT EXISTS questions (
  id VARCHAR(64) PRIMARY KEY,
  couple_id VARCHAR(64) REFERENCES couples(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  category VARCHAR(32) NOT NULL,
  p1_answer TEXT,
  p2_answer TEXT,
  p1_answered_at TIMESTAMP WITH TIME ZONE,
  p2_answered_at TIMESTAMP WITH TIME ZONE,
  is_revealed BOOLEAN DEFAULT FALSE,
  is_saved BOOLEAN DEFAULT FALSE,
  is_daily BOOLEAN DEFAULT FALSE,
  daily_date VARCHAR(32),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_questions_couple_id ON questions(couple_id);
CREATE INDEX IF NOT EXISTS idx_questions_daily_date ON questions(couple_id, daily_date);

CREATE TABLE IF NOT EXISTS games (
  id VARCHAR(64) PRIMARY KEY,
  couple_id VARCHAR(64) REFERENCES couples(id) ON DELETE CASCADE,
  game_type VARCHAR(32) NOT NULL,
  title VARCHAR(255) NOT NULL,
  status VARCHAR(32) DEFAULT 'active',
  current_turn_partner VARCHAR(32) DEFAULT 'both',
  streak_count INT DEFAULT 0,
  game_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_games_couple_id ON games(couple_id);

CREATE TABLE IF NOT EXISTS plans (
  id VARCHAR(64) PRIMARY KEY,
  couple_id VARCHAR(64) REFERENCES couples(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  plan_type VARCHAR(32) NOT NULL,
  start_date VARCHAR(32) NOT NULL,
  end_date VARCHAR(32),
  location VARCHAR(255),
  notes TEXT,
  budget NUMERIC(10, 2) DEFAULT 0,
  itinerary JSONB DEFAULT '[]'::jsonb,
  expenses JSONB DEFAULT '[]'::jsonb,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_plans_couple_id ON plans(couple_id);

CREATE TABLE IF NOT EXISTS reminders (
  id VARCHAR(64) PRIMARY KEY,
  couple_id VARCHAR(64) REFERENCES couples(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  note TEXT,
  scheduled_at VARCHAR(64),
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_rule VARCHAR(32) DEFAULT 'none',
  assigned_to VARCHAR(32) DEFAULT 'both',
  style VARCHAR(32) DEFAULT 'gentle',
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP WITH TIME ZONE,
  reaction VARCHAR(32),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_reminders_couple_id ON reminders(couple_id);

CREATE TABLE IF NOT EXISTS cute_messages (
  id VARCHAR(64) PRIMARY KEY,
  couple_id VARCHAR(64) REFERENCES couples(id) ON DELETE CASCADE,
  sender_partner VARCHAR(32) NOT NULL,
  message_type VARCHAR(32) NOT NULL,
  content TEXT,
  is_surprise BOOLEAN DEFAULT FALSE,
  reveal_at TIMESTAMP WITH TIME ZONE,
  is_opened BOOLEAN DEFAULT TRUE,
  reaction VARCHAR(32),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_cute_messages_couple_id ON cute_messages(couple_id);

CREATE TABLE IF NOT EXISTS memories (
  id VARCHAR(64) PRIMARY KEY,
  couple_id VARCHAR(64) REFERENCES couples(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  caption TEXT,
  memory_date VARCHAR(32) NOT NULL,
  media_urls JSONB DEFAULT '[]'::jsonb,
  location VARCHAR(255),
  tags JSONB DEFAULT '[]'::jsonb,
  linked_plan_id VARCHAR(64),
  linked_wishlist_id VARCHAR(64),
  favorite BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_memories_couple_id ON memories(couple_id);
CREATE INDEX IF NOT EXISTS idx_memories_date ON memories(couple_id, memory_date);

CREATE TABLE IF NOT EXISTS journal_entries (
  id VARCHAR(64) PRIMARY KEY,
  couple_id VARCHAR(64) REFERENCES couples(id) ON DELETE CASCADE,
  author_partner VARCHAR(32) NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  mood VARCHAR(32) DEFAULT 'Happy',
  reflection_prompt TEXT,
  tags JSONB DEFAULT '[]'::jsonb,
  photos JSONB DEFAULT '[]'::jsonb,
  linked_question_id VARCHAR(64),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_journal_couple_id ON journal_entries(couple_id);

CREATE TABLE IF NOT EXISTS wishlist_items (
  id VARCHAR(64) PRIMARY KEY,
  couple_id VARCHAR(64) REFERENCES couples(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  category VARCHAR(32) NOT NULL,
  notes TEXT,
  link_url TEXT,
  image_url TEXT,
  priority VARCHAR(16) DEFAULT 'medium',
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP WITH TIME ZONE,
  converted_to_plan_id VARCHAR(64),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wishlist_couple_id ON wishlist_items(couple_id);
