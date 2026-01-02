/*
  # Add Rebirth System

  1. New Table
    - `player_rebirths` - Tracks rebirth history and bonuses
      - `id` (uuid, primary key)
      - `player_id` (uuid, foreign key)
      - `rebirth_count` (integer) - Total number of rebirths
      - `total_rebirths_gold_earned` (numeric) - Cumulative gold from all rebirths
      - `rebirth_bonus_multiplier` (numeric) - Permanent multiplier from rebirths (1.05x per rebirth)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `player_rebirths` table
    - Add policy for users to read/update their own rebirth data

  3. Details
    - Rebirth system allows players to reset their progress for permanent bonuses
    - Each rebirth grants: 5% gold multiplier, 5% merge multiplier
    - Players receive a rebirth bonus equal to 20% of their current gold
    - All permanent upgrades are preserved across rebirths
*/

CREATE TABLE IF NOT EXISTS player_rebirths (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  rebirth_count integer DEFAULT 0,
  total_rebirths_gold_earned numeric DEFAULT 0,
  rebirth_bonus_gold_multiplier numeric DEFAULT 1.0,
  rebirth_bonus_merge_multiplier numeric DEFAULT 1.0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

ALTER TABLE player_rebirths ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own rebirth data"
  ON player_rebirths FOR SELECT
  TO authenticated
  USING (auth.uid() = player_id);

CREATE POLICY "Users can update their own rebirth data"
  ON player_rebirths FOR UPDATE
  TO authenticated
  USING (auth.uid() = player_id)
  WITH CHECK (auth.uid() = player_id);

CREATE POLICY "Users can insert their own rebirth data"
  ON player_rebirths FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = player_id);
