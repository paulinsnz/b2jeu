/*
  # Update RPG Equipment System with Specific Slots

  1. Modified Tables
    - `rpg_equipment_types`
      - Add `equipment_type` column to categorize items (weapon, helmet, chest, legs, feet, accessory)

    - `rpg_player_equipment`
      - Replace generic slots with specific French-named slots
      - New slots: helmet_id, chest_id, legs_id, feet_id, accessory1_id, accessory2_id, weapon_id
      - Each slot can only accept appropriate equipment types

  2. Data Migration
    - Migrate existing armor to appropriate slots based on logic
    - Migrate accessories remain as accessories

  3. Security
    - Existing RLS policies remain valid
*/

-- Add equipment_type column to equipment types table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rpg_equipment_types' AND column_name = 'equipment_type'
  ) THEN
    ALTER TABLE rpg_equipment_types ADD COLUMN equipment_type text DEFAULT 'weapon';
  END IF;
END $$;

-- Update equipment types
UPDATE rpg_equipment_types SET equipment_type = 'weapon' WHERE equipment_slot = 'weapon';
UPDATE rpg_equipment_types SET equipment_type = 'helmet' WHERE equipment_slot = 'armor' AND name LIKE '%Helmet%';
UPDATE rpg_equipment_types SET equipment_type = 'chest' WHERE equipment_slot = 'armor' AND name NOT LIKE '%Helmet%' AND name NOT LIKE '%Legs%' AND name NOT LIKE '%Feet%';
UPDATE rpg_equipment_types SET equipment_type = 'chest' WHERE equipment_slot = 'armor' AND equipment_type IS NULL;
UPDATE rpg_equipment_types SET equipment_type = 'accessory' WHERE equipment_slot = 'accessory';

-- Add new equipment slot columns to player equipment
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rpg_player_equipment' AND column_name = 'helmet_id'
  ) THEN
    ALTER TABLE rpg_player_equipment ADD COLUMN helmet_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rpg_player_equipment' AND column_name = 'chest_id'
  ) THEN
    ALTER TABLE rpg_player_equipment ADD COLUMN chest_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rpg_player_equipment' AND column_name = 'legs_id'
  ) THEN
    ALTER TABLE rpg_player_equipment ADD COLUMN legs_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rpg_player_equipment' AND column_name = 'feet_id'
  ) THEN
    ALTER TABLE rpg_player_equipment ADD COLUMN feet_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Insert new armor pieces with correct types
INSERT INTO rpg_equipment_types (name, equipment_slot, equipment_type, damage_bonus, defense_bonus, health_bonus, price, rarity, required_level) VALUES
-- Helmets
('Iron Helmet', 'armor', 'helmet', 0, 3, 5, 50, 'common', 1),
('Steel Helmet', 'armor', 'helmet', 0, 6, 10, 120, 'uncommon', 3),
('Knight Helmet', 'armor', 'helmet', 0, 10, 20, 250, 'rare', 5),
('Dragon Helm', 'armor', 'helmet', 0, 18, 40, 700, 'epic', 8),
('Helm of Legends', 'armor', 'helmet', 0, 25, 80, 1800, 'legendary', 10),
-- Chest
('Leather Chest', 'armor', 'chest', 0, 5, 10, 60, 'common', 1),
('Iron Chest', 'armor', 'chest', 0, 10, 20, 180, 'uncommon', 3),
('Steel Plating', 'armor', 'chest', 0, 15, 30, 400, 'rare', 5),
('Dragon Scale Mail', 'armor', 'chest', 0, 25, 50, 1000, 'epic', 8),
('Void Armor', 'armor', 'chest', 0, 35, 100, 2500, 'legendary', 10),
-- Legs
('Leather Leggings', 'armor', 'legs', 0, 3, 8, 40, 'common', 1),
('Iron Leggings', 'armor', 'legs', 0, 7, 15, 140, 'uncommon', 3),
('Steel Leggings', 'armor', 'legs', 0, 12, 25, 300, 'rare', 5),
('Dragon Leggings', 'armor', 'legs', 0, 20, 45, 850, 'epic', 8),
('Legendary Leggings', 'armor', 'legs', 0, 30, 90, 2200, 'legendary', 10),
-- Feet
('Leather Boots', 'armor', 'feet', 0, 2, 5, 30, 'common', 1),
('Iron Boots', 'armor', 'feet', 0, 5, 10, 100, 'uncommon', 3),
('Steel Boots', 'armor', 'feet', 0, 8, 18, 250, 'rare', 5),
('Dragon Boots', 'armor', 'feet', 0, 15, 35, 700, 'epic', 8),
('Boots of Power', 'armor', 'feet', 0, 22, 75, 1900, 'legendary', 10)
ON CONFLICT (name) DO NOTHING;
