-- Système de Défis Quotidiens et Monde d'Événements
-- Tables: players, daily_challenges, event_runs, permanent_upgrades

CREATE TABLE IF NOT EXISTS players (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_name text NOT NULL DEFAULT 'Player',
  event_currency numeric DEFAULT 0,
  permanent_gold_multiplier numeric DEFAULT 1,
  permanent_merge_multiplier numeric DEFAULT 1,
  permanent_xp_multiplier numeric DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS daily_challenges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid REFERENCES players(id) ON DELETE CASCADE,
  challenge_type text NOT NULL,
  target integer NOT NULL,
  current_progress integer DEFAULT 0,
  reward_type text NOT NULL,
  reward_amount numeric NOT NULL,
  completed boolean DEFAULT false,
  expires_at timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS event_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid REFERENCES players(id) ON DELETE CASCADE,
  wave_number integer DEFAULT 1,
  gold_earned numeric DEFAULT 0,
  merges_count integer DEFAULT 0,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  completed_at timestamptz
);

CREATE TABLE IF NOT EXISTS permanent_upgrades (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid REFERENCES players(id) ON DELETE CASCADE,
  upgrade_type text NOT NULL,
  level integer DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(player_id, upgrade_type)
);

ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE permanent_upgrades ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players can read all player data"
  ON players FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Players can insert their own data"
  ON players FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Players can update their own data"
  ON players FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Players can read their own challenges"
  ON daily_challenges FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Players can insert their own challenges"
  ON daily_challenges FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Players can update their own challenges"
  ON daily_challenges FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Players can delete their own challenges"
  ON daily_challenges FOR DELETE
  TO authenticated
  USING (true);

CREATE POLICY "Players can read their own event runs"
  ON event_runs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Players can insert their own event runs"
  ON event_runs FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Players can update their own event runs"
  ON event_runs FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Players can read their own upgrades"
  ON permanent_upgrades FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Players can insert their own upgrades"
  ON permanent_upgrades FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Players can update their own upgrades"
  ON permanent_upgrades FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);