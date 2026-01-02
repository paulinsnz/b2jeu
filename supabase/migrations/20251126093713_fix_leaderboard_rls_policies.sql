/*
  # Fix Leaderboard RLS Policies

  1. Security Updates
    - Allow authenticated users to update their own leaderboard entries
    - Allow authenticated users to insert their own leaderboard entries
*/

DROP POLICY IF EXISTS "Public can read leaderboard" ON leaderboard_cache;
DROP POLICY IF EXISTS "Authenticated can read leaderboard" ON leaderboard_cache;

CREATE POLICY "Everyone can read leaderboard"
  ON leaderboard_cache FOR SELECT
  TO public, authenticated
  USING (true);

CREATE POLICY "Users can insert their own leaderboard entry"
  ON leaderboard_cache FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = player_id);

CREATE POLICY "Users can update their own leaderboard entry"
  ON leaderboard_cache FOR UPDATE
  TO authenticated
  USING (auth.uid() = player_id)
  WITH CHECK (auth.uid() = player_id);