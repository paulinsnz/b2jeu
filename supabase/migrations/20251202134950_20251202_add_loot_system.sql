/*
  # Add Loot Drop System for RPG Equipment

  1. New Tables
    - `rpg_monster_loot` - Associates equipment drops to monsters with drop rates based on difficulty
      - `id` (uuid, primary key)
      - `monster_name` (text) - Name of the monster
      - `equipment_id` (uuid, foreign key) - Equipment that can drop
      - `drop_rate` (numeric) - Chance to drop (0-100%)
      - `difficulty_level` (integer) - Monster difficulty (1-10)
      - `created_at` (timestamp)

  2. Modified Tables
    - `rpg_equipment_types`
      - Add `drop_rate` column for base drop rate

  3. Security
    - Enable RLS on `rpg_monster_loot` table
    - Public read access to monster loot tables

  4. Important Notes
    - Drop rates scale with monster difficulty
    - Higher difficulty = better equipment drops
    - Each monster can drop multiple pieces of equipment
*/

-- Add drop_rate column to equipment types if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rpg_equipment_types' AND column_name = 'drop_rate'
  ) THEN
    ALTER TABLE rpg_equipment_types ADD COLUMN drop_rate numeric DEFAULT 5;
  END IF;
END $$;

-- Create monster loot table
CREATE TABLE IF NOT EXISTS rpg_monster_loot (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  monster_name text NOT NULL,
  equipment_id uuid NOT NULL REFERENCES rpg_equipment_types(id) ON DELETE CASCADE,
  drop_rate numeric DEFAULT 5,
  difficulty_level integer DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  UNIQUE(monster_name, equipment_id)
);

-- Enable RLS
ALTER TABLE rpg_monster_loot ENABLE ROW LEVEL SECURITY;

-- Public read access to monster loot
CREATE POLICY "Monster loot readable by everyone"
  ON rpg_monster_loot FOR SELECT
  TO authenticated, anon
  USING (true);

-- Add loot associations for each monster with difficulty-scaled drops
-- Goblin (Level 1, Difficulty 1)
INSERT INTO rpg_monster_loot (monster_name, equipment_id, drop_rate, difficulty_level)
SELECT 'Goblin', id, 15, 1 FROM rpg_equipment_types WHERE rarity = 'common'
ON CONFLICT DO NOTHING;

-- Orc (Level 2, Difficulty 2)
INSERT INTO rpg_monster_loot (monster_name, equipment_id, drop_rate, difficulty_level)
SELECT 'Orc', id, 20, 2 FROM rpg_equipment_types WHERE rarity IN ('common', 'uncommon')
ON CONFLICT DO NOTHING;

-- Skeleton Warrior (Level 2, Difficulty 2)
INSERT INTO rpg_monster_loot (monster_name, equipment_id, drop_rate, difficulty_level)
SELECT 'Skeleton Warrior', id, 20, 2 FROM rpg_equipment_types WHERE rarity IN ('common', 'uncommon')
ON CONFLICT DO NOTHING;

-- Shadow Beast (Level 3, Difficulty 3)
INSERT INTO rpg_monster_loot (monster_name, equipment_id, drop_rate, difficulty_level)
SELECT 'Shadow Beast', id, 25, 3 FROM rpg_equipment_types WHERE rarity IN ('uncommon', 'rare')
ON CONFLICT DO NOTHING;

-- Troll (Level 3, Difficulty 3)
INSERT INTO rpg_monster_loot (monster_name, equipment_id, drop_rate, difficulty_level)
SELECT 'Troll', id, 25, 3 FROM rpg_equipment_types WHERE rarity IN ('uncommon', 'rare')
ON CONFLICT DO NOTHING;

-- Dark Wizard (Level 4, Difficulty 4)
INSERT INTO rpg_monster_loot (monster_name, equipment_id, drop_rate, difficulty_level)
SELECT 'Dark Wizard', id, 30, 4 FROM rpg_equipment_types WHERE rarity IN ('rare', 'epic')
ON CONFLICT DO NOTHING;

-- Dragon Spawn (Level 4, Difficulty 4)
INSERT INTO rpg_monster_loot (monster_name, equipment_id, drop_rate, difficulty_level)
SELECT 'Dragon Spawn', id, 30, 4 FROM rpg_equipment_types WHERE rarity IN ('rare', 'epic')
ON CONFLICT DO NOTHING;

-- Ice Wraith (Level 5, Difficulty 5)
INSERT INTO rpg_monster_loot (monster_name, equipment_id, drop_rate, difficulty_level)
SELECT 'Ice Wraith', id, 35, 5 FROM rpg_equipment_types WHERE rarity IN ('rare', 'epic')
ON CONFLICT DO NOTHING;

-- Frost Giant (Level 5, Difficulty 5)
INSERT INTO rpg_monster_loot (monster_name, equipment_id, drop_rate, difficulty_level)
SELECT 'Frost Giant', id, 35, 5 FROM rpg_equipment_types WHERE rarity IN ('epic', 'legendary')
ON CONFLICT DO NOTHING;

-- Fire Demon (Level 6, Difficulty 6)
INSERT INTO rpg_monster_loot (monster_name, equipment_id, drop_rate, difficulty_level)
SELECT 'Fire Demon', id, 40, 6 FROM rpg_equipment_types WHERE rarity IN ('epic', 'legendary')
ON CONFLICT DO NOTHING;
