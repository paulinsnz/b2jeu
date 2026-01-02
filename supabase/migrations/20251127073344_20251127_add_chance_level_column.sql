/*
  # Add chance_level column to player_progression table

  1. New Columns
    - `chance_level` (integer, default 0) - Tracks the chance upgrade level for rare item spawning

  2. Changes
    - Adds chance_level column to player_progression table with default value of 0
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'player_progression' AND column_name = 'chance_level'
  ) THEN
    ALTER TABLE player_progression ADD COLUMN chance_level integer DEFAULT 0;
  END IF;
END $$;