/*
  # Create Leaderboard System

  1. New Tables
    - `leaderboard_cache`
      - `id` (uuid, primary key)
      - `player_id` (uuid, references players table)
      - `player_name` (text) - cached player name for performance
      - `score` (numeric) - current gold amount
      - `rank` (integer) - calculated rank
      - `updated_at` (timestamptz) - last update time

  2. Indexes
    - Index on `score` DESC for efficient leaderboard queries
    - Index on `updated_at` for cache invalidation

  3. Security
    - Enable RLS on `leaderboard_cache` table
    - Add policy for public read access to leaderboard
*/

CREATE TABLE IF NOT EXISTS leaderboard_cache (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  player_name text NOT NULL DEFAULT 'Player',
  score numeric NOT NULL DEFAULT 0,
  rank integer,
  updated_at timestamptz DEFAULT now(),
  UNIQUE(player_id)
);

CREATE INDEX IF NOT EXISTS idx_leaderboard_score 
  ON leaderboard_cache(score DESC);

CREATE INDEX IF NOT EXISTS idx_leaderboard_updated_at 
  ON leaderboard_cache(updated_at DESC);

ALTER TABLE leaderboard_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can read leaderboard"
  ON leaderboard_cache FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated can read leaderboard"
  ON leaderboard_cache FOR SELECT
  TO authenticated
  USING (true);