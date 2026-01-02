/*
  # Add Player Progression Table
  
  1. New Tables
    - `player_progression`
      - `id` (uuid, primary key)
      - `player_id` (uuid, references players table)
      - `board` (jsonb) - the game board state
      - `board_size` (integer) - size of the board
      - `score` (numeric) - current gold amount
      - `level_multipliers` (jsonb) - multipliers for each level
      - `add_item_cost` (numeric) - current cost to add items
      - `items_added` (integer) - total items added
      - `event_currency` (numeric) - event currency amount
      - `permanent_gold_multiplier` (numeric)
      - `permanent_merge_multiplier` (numeric)
      - `permanent_xp_multiplier` (numeric)
      - `total_merges` (integer)
      - `total_gold_earned` (numeric)
      - `premium_currency` (numeric)
      - `active_boosts` (jsonb)
      - `player_level` (integer)
      - `player_xp` (numeric)
      - `used_codes` (text[])
      - `achievements` (jsonb)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `player_progression` table
    - Add policies for authenticated users to access only their own progression
*/

CREATE TABLE IF NOT EXISTS player_progression (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid REFERENCES players(id) ON DELETE CASCADE,
  board jsonb DEFAULT '[]'::jsonb,
  board_size integer DEFAULT 9,
  score numeric DEFAULT 50,
  level_multipliers jsonb DEFAULT '{}'::jsonb,
  add_item_cost numeric DEFAULT 10,
  items_added integer DEFAULT 0,
  event_currency numeric DEFAULT 0,
  permanent_gold_multiplier numeric DEFAULT 1,
  permanent_merge_multiplier numeric DEFAULT 1,
  permanent_xp_multiplier numeric DEFAULT 1,
  total_merges integer DEFAULT 0,
  total_gold_earned numeric DEFAULT 50,
  premium_currency numeric DEFAULT 0,
  active_boosts jsonb DEFAULT '{}'::jsonb,
  player_level integer DEFAULT 1,
  player_xp numeric DEFAULT 0,
  used_codes text[] DEFAULT '{}',
  achievements jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(player_id)
);

ALTER TABLE player_progression ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players can read their own progression"
  ON player_progression FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Players can insert their own progression"
  ON player_progression FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Players can update their own progression"
  ON player_progression FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);
