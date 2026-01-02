/*
  # Add Auto Buy Feature Column

  1. Modified Tables
    - `player_progression`
      - Added `auto_buy_enabled` column to store the state of auto-buying robot

  2. Description
    - Adds support for saving the auto-buy robot state
    - Defaults to false for all existing and new records
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'player_progression' AND column_name = 'auto_buy_enabled'
  ) THEN
    ALTER TABLE player_progression ADD COLUMN auto_buy_enabled BOOLEAN DEFAULT false;
  END IF;
END $$;