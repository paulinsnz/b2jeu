/*
  # Create player upgrades table

  1. New Tables
    - `player_upgrades`
      - `id` (uuid, primary key)
      - `player_id` (uuid, foreign key to auth.users)
      - `parcel_cost` (numeric, current cost for parcel upgrades)
      - `parcel_purchased_count` (integer, number of times purchased)
      - `level_1_cost` to `level_10_cost` (numeric, costs for each level upgrade)
      - `chance_level` (integer, current chance upgrade level)
      - `chance_cost` (numeric, current cost for chance upgrade)
      - `max_level_upgrade` (integer, current max level)
      - `max_level_cost` (numeric, current cost for max level upgrade)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `player_upgrades` table
    - Add policy for players to read/write their own upgrade data
    - Add policy for players to manage their own upgrades
*/

CREATE TABLE IF NOT EXISTS player_upgrades (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  parcel_cost numeric DEFAULT 200,
  parcel_purchased_count integer DEFAULT 0,
  level_1_cost numeric DEFAULT 50,
  level_2_cost numeric DEFAULT 100,
  level_3_cost numeric DEFAULT 150,
  level_4_cost numeric DEFAULT 250,
  level_5_cost numeric DEFAULT 400,
  level_6_cost numeric DEFAULT 600,
  level_7_cost numeric DEFAULT 900,
  level_8_cost numeric DEFAULT 1300,
  level_9_cost numeric DEFAULT 1800,
  level_10_cost numeric DEFAULT 2500,
  chance_level integer DEFAULT 0,
  chance_cost numeric DEFAULT 100,
  max_level_upgrade integer DEFAULT 5,
  max_level_cost numeric DEFAULT 500,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(player_id)
);

ALTER TABLE player_upgrades ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players can read own upgrade data"
  ON player_upgrades FOR SELECT
  TO authenticated
  USING (auth.uid() = player_id);

CREATE POLICY "Players can update own upgrade data"
  ON player_upgrades FOR UPDATE
  TO authenticated
  USING (auth.uid() = player_id)
  WITH CHECK (auth.uid() = player_id);

CREATE POLICY "Players can insert own upgrade data"
  ON player_upgrades FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = player_id);
