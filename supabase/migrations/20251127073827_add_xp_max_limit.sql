/*
  # Add XP Max Limit Column

  1. New Columns
    - `xp_max_limit` (integer, default 5)
      - Stores the maximum XP required to level up (can be upgraded)
  2. Updates
    - Add column to player_progression table
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'player_progression' AND column_name = 'xp_max_limit'
  ) THEN
    ALTER TABLE player_progression ADD COLUMN xp_max_limit integer DEFAULT 5;
  END IF;
END $$;