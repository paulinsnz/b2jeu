/*
  # Add Auto-Sell Settings System

  1. New Tables
    - `rpg_auto_sell_settings` - stores player auto-sell preferences by rarity level

  2. Columns
    - `id` (uuid, primary key)
    - `player_id` (uuid, foreign key to auth.users)
    - `rarity` (text) - common, uncommon, rare, epic, legendary
    - `enabled` (boolean) - whether to auto-sell this rarity
    - `created_at` (timestamp)
    - `updated_at` (timestamp)

  3. Security
    - Enable RLS on `rpg_auto_sell_settings` table
    - Add policy for players to manage their own auto-sell settings
*/

CREATE TABLE IF NOT EXISTS rpg_auto_sell_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rarity text NOT NULL CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')),
  enabled boolean NOT NULL DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(player_id, rarity)
);

ALTER TABLE rpg_auto_sell_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players can manage their auto-sell settings"
  ON rpg_auto_sell_settings
  FOR ALL
  TO authenticated
  USING (auth.uid() = player_id)
  WITH CHECK (auth.uid() = player_id);

-- Initialize auto-sell settings for new players (default: all disabled)
INSERT INTO rpg_auto_sell_settings (player_id, rarity, enabled)
SELECT DISTINCT player_id, rarity, false
FROM (
  SELECT DISTINCT rpe.player_id, 'common' as rarity
  FROM rpg_player_equipment rpe
  UNION ALL
  SELECT DISTINCT rpe.player_id, 'uncommon' as rarity
  FROM rpg_player_equipment rpe
  UNION ALL
  SELECT DISTINCT rpe.player_id, 'rare' as rarity
  FROM rpg_player_equipment rpe
  UNION ALL
  SELECT DISTINCT rpe.player_id, 'epic' as rarity
  FROM rpg_player_equipment rpe
  UNION ALL
  SELECT DISTINCT rpe.player_id, 'legendary' as rarity
  FROM rpg_player_equipment rpe
) t
ON CONFLICT (player_id, rarity) DO NOTHING;
