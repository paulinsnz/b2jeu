/*
  # Add RPG Combat System

  1. New Tables
    - `rpg_gold` - Track player gold currency earned from combat
      - `id` (uuid, primary key)
      - `player_id` (uuid, foreign key to players)
      - `amount` (numeric, total gold earned)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `rpg_combat_logs` - Track combat history
      - `id` (uuid, primary key)
      - `player_id` (uuid, foreign key to players)
      - `monster_name` (text)
      - `gold_earned` (numeric)
      - `xp_earned` (numeric)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Add policies for authenticated users to read/write their own data
    
  3. Notes
    - Gold is a new currency earned by defeating monsters in RPG world
    - Combat logs track all monster defeats for statistics
*/

CREATE TABLE IF NOT EXISTS rpg_gold (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid NOT NULL UNIQUE,
  amount numeric DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS rpg_combat_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid NOT NULL,
  monster_name text NOT NULL,
  gold_earned numeric NOT NULL,
  xp_earned numeric NOT NULL,
  created_at timestamptz DEFAULT now(),
  FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

ALTER TABLE rpg_gold ENABLE ROW LEVEL SECURITY;
ALTER TABLE rpg_combat_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own gold"
  ON rpg_gold FOR SELECT
  TO authenticated
  USING (auth.uid() = player_id);

CREATE POLICY "Users can update own gold"
  ON rpg_gold FOR UPDATE
  TO authenticated
  USING (auth.uid() = player_id)
  WITH CHECK (auth.uid() = player_id);

CREATE POLICY "Users can insert own gold"
  ON rpg_gold FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = player_id);

CREATE POLICY "Users can view own combat logs"
  ON rpg_combat_logs FOR SELECT
  TO authenticated
  USING (auth.uid() = player_id);

CREATE POLICY "Users can insert own combat logs"
  ON rpg_combat_logs FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = player_id);
