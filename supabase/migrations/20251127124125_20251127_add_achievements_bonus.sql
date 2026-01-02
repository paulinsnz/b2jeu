/*
  # Add achievement bonus multiplier

  1. New Columns
    - `achievement_gold_bonus` (numeric) - Stores the cumulative gold bonus from achievements (+1% per unlocked achievement)
  
  2. Changes
    - Added to `player_progression` table
    - Defaults to 0 (no bonus initially)
    - Used to calculate total gold multiplier effect

  3. Security
    - RLS policies remain unchanged as this is a player data update
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'player_progression' AND column_name = 'achievement_gold_bonus'
  ) THEN
    ALTER TABLE player_progression ADD COLUMN achievement_gold_bonus numeric DEFAULT 0;
  END IF;
END $$;