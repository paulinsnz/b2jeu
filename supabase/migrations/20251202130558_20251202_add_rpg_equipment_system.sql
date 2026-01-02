/*
  # Create RPG Equipment System

  1. New Tables
    - `rpg_equipment_types`
      - `id` (uuid, primary key)
      - `name` (text, unique) - nom de l'équipement
      - `equipment_slot` (text) - type d'équipement (weapon, armor, accessory)
      - `damage_bonus` (numeric) - bonus de dégâts
      - `defense_bonus` (numeric) - bonus de défense
      - `health_bonus` (numeric) - bonus de PV
      - `price` (numeric) - prix d'achat
      - `rarity` (text) - rareté (common, uncommon, rare, epic, legendary)
      - `required_level` (integer) - niveau requis
      - `created_at` (timestamp)

    - `rpg_player_equipment`
      - `id` (uuid, primary key)
      - `player_id` (uuid, foreign key)
      - `weapon_id` (uuid, foreign key) - arme équipée
      - `armor_id` (uuid, foreign key) - armure équipée
      - `accessory1_id` (uuid, foreign key) - accessoire 1
      - `accessory2_id` (uuid, foreign key) - accessoire 2
      - `inventory` (jsonb) - inventaire d'équipement
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Add policies for players to manage their own equipment
    - Add policy for reading equipment types (public read)

  3. Important Notes
    - Equipment affects combat damage and defense
    - Players can buy equipment with gold
    - Equipment is stored in player equipment table
*/

-- Create equipment types table
CREATE TABLE IF NOT EXISTS rpg_equipment_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  equipment_slot text NOT NULL,
  damage_bonus numeric DEFAULT 0,
  defense_bonus numeric DEFAULT 0,
  health_bonus numeric DEFAULT 0,
  price numeric NOT NULL,
  rarity text DEFAULT 'common',
  required_level integer DEFAULT 1,
  created_at timestamptz DEFAULT now()
);

-- Create player equipment table
CREATE TABLE IF NOT EXISTS rpg_player_equipment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id uuid NOT NULL UNIQUE REFERENCES public.players(id) ON DELETE CASCADE,
  weapon_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL,
  armor_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL,
  accessory1_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL,
  accessory2_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL,
  inventory jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE rpg_equipment_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE rpg_player_equipment ENABLE ROW LEVEL SECURITY;

-- Policies for equipment types (public read)
CREATE POLICY "Equipment types readable by everyone"
  ON rpg_equipment_types FOR SELECT
  TO authenticated, anon
  USING (true);

-- Policies for player equipment
CREATE POLICY "Players can read own equipment"
  ON rpg_player_equipment FOR SELECT
  TO authenticated
  USING (player_id = auth.uid());

CREATE POLICY "Players can update own equipment"
  ON rpg_player_equipment FOR UPDATE
  TO authenticated
  USING (player_id = auth.uid())
  WITH CHECK (player_id = auth.uid());

CREATE POLICY "Players can insert own equipment"
  ON rpg_player_equipment FOR INSERT
  TO authenticated
  WITH CHECK (player_id = auth.uid());

-- Insert default equipment
INSERT INTO rpg_equipment_types (name, equipment_slot, damage_bonus, defense_bonus, health_bonus, price, rarity, required_level) VALUES
-- Weapons
('Iron Sword', 'weapon', 5, 0, 0, 50, 'common', 1),
('Steel Sword', 'weapon', 10, 0, 0, 150, 'uncommon', 3),
('Ancient Blade', 'weapon', 15, 0, 0, 300, 'rare', 5),
('Dragon Slayer', 'weapon', 25, 0, 0, 800, 'epic', 8),
('Excalibur', 'weapon', 35, 0, 0, 2000, 'legendary', 10),
-- Armor
('Leather Armor', 'armor', 0, 5, 10, 60, 'common', 1),
('Iron Armor', 'armor', 0, 10, 20, 180, 'uncommon', 3),
('Steel Plating', 'armor', 0, 15, 30, 400, 'rare', 5),
('Dragon Scale Mail', 'armor', 0, 25, 50, 1000, 'epic', 8),
('Void Armor', 'armor', 0, 35, 100, 2500, 'legendary', 10),
-- Accessories
('Gold Ring', 'accessory', 2, 2, 5, 40, 'common', 1),
('Enchanted Ring', 'accessory', 5, 5, 15, 150, 'uncommon', 3),
('Mithril Band', 'accessory', 8, 8, 30, 350, 'rare', 5),
('Ring of Power', 'accessory', 15, 15, 60, 900, 'epic', 8),
('Infinite Ring', 'accessory', 25, 25, 150, 2200, 'legendary', 10)
ON CONFLICT (name) DO NOTHING;
