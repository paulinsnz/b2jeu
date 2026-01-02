/*
  # Add max_level_upgrade column to player_progression table

  1. Changes
    - Add `max_level_upgrade` column to `player_progression` table
    - This column stores the maximum level that items can reach
    - Starts at 5 and can be upgraded in the shop

  2. Important Notes
    - Default value set to 5 for all existing and new records
    - Allows players to increase item level caps through shop upgrades
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'player_progression' AND column_name = 'max_level_upgrade'
  ) THEN
    ALTER TABLE player_progression ADD COLUMN max_level_upgrade INTEGER DEFAULT 5;
  END IF;
END $$;