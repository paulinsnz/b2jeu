/*
  # Add current theme column to player progression

  1. Changes
    - Add `current_theme` column to `player_progression` table
    - Default value set to 'default'
    - Column stores theme preference (default, brown, etc)

  2. Migration Details
    - Safe: Uses IF NOT EXISTS to prevent errors if column already exists
    - Non-destructive: Only adds a new column
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'player_progression' AND column_name = 'current_theme'
  ) THEN
    ALTER TABLE player_progression ADD COLUMN current_theme text DEFAULT 'default';
  END IF;
END $$;