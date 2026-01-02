/*
  # Update Equipment System to Support Specific Armor Slots

  1. Changes to Tables
    - `rpg_equipment_types` - add equipment_type column to differentiate armor pieces
    - `rpg_player_equipment` - replace armor_id with helmet_id, chest_id, legs_id, feet_id

  2. New Columns
    - `rpg_equipment_types.equipment_type` - specific type (helmet, chest, legs, feet, accessory)
    - `rpg_player_equipment.helmet_id` - equipped helmet
    - `rpg_player_equipment.chest_id` - equipped chest armor
    - `rpg_player_equipment.legs_id` - equipped leg armor
    - `rpg_player_equipment.feet_id` - equipped feet armor

  3. Data Migration
    - Equipment slots are now categorized: weapon, helmet, chest, legs, feet, accessory1, accessory2
    - Old 'armor' type equipment is preserved

  4. Important Notes
    - Accessories can be equipped to accessory1 or accessory2 slots
    - Armor pieces now have specific body part slots
*/

-- Add equipment_type column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rpg_equipment_types' AND column_name = 'equipment_type'
  ) THEN
    ALTER TABLE rpg_equipment_types ADD COLUMN equipment_type text;
  END IF;
END $$;

-- Update existing equipment types to set equipment_type based on equipment_slot
UPDATE rpg_equipment_types 
SET equipment_type = equipment_slot
WHERE equipment_type IS NULL;

-- Add individual armor piece columns to player equipment
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rpg_player_equipment' AND column_name = 'helmet_id'
  ) THEN
    ALTER TABLE rpg_player_equipment ADD COLUMN helmet_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rpg_player_equipment' AND column_name = 'chest_id'
  ) THEN
    ALTER TABLE rpg_player_equipment ADD COLUMN chest_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rpg_player_equipment' AND column_name = 'legs_id'
  ) THEN
    ALTER TABLE rpg_player_equipment ADD COLUMN legs_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'rpg_player_equipment' AND column_name = 'feet_id'
  ) THEN
    ALTER TABLE rpg_player_equipment ADD COLUMN feet_id uuid REFERENCES rpg_equipment_types(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Add new armor pieces to equipment types with proper categorization
INSERT INTO rpg_equipment_types (name, equipment_slot, equipment_type, damage_bonus, defense_bonus, health_bonus, price, rarity, required_level) VALUES
-- Helmets
('Iron Helmet', 'helmet', 'helmet', 0, 3, 5, 40, 'common', 1),
('Steel Helm', 'helmet', 'helmet', 0, 6, 10, 120, 'uncommon', 3),
('Dragon Helm', 'helmet', 'helmet', 0, 10, 20, 300, 'rare', 5),
('Crown of Power', 'helmet', 'helmet', 0, 18, 40, 800, 'epic', 8),
('Helm of Eternity', 'helmet', 'helmet', 0, 25, 80, 2000, 'legendary', 10),
-- Chest Armor
('Leather Chest', 'chest', 'chest', 0, 5, 10, 50, 'common', 1),
('Iron Breastplate', 'chest', 'chest', 0, 10, 20, 150, 'uncommon', 3),
('Steel Plate', 'chest', 'chest', 0, 15, 30, 350, 'rare', 5),
('Dragon Scale Plate', 'chest', 'chest', 0, 25, 50, 900, 'epic', 8),
('Void Plate', 'chest', 'chest', 0, 35, 100, 2200, 'legendary', 10),
-- Leg Armor
('Leather Legs', 'legs', 'legs', 0, 3, 8, 35, 'common', 1),
('Iron Legs', 'legs', 'legs', 0, 6, 15, 100, 'uncommon', 3),
('Steel Legs', 'legs', 'legs', 0, 10, 25, 250, 'rare', 5),
('Dragon Scale Legs', 'legs', 'legs', 0, 18, 40, 700, 'epic', 8),
('Void Legs', 'legs', 'legs', 0, 25, 80, 1800, 'legendary', 10),
-- Feet Armor
('Leather Boots', 'feet', 'feet', 0, 2, 5, 30, 'common', 1),
('Iron Boots', 'feet', 'feet', 0, 4, 10, 80, 'uncommon', 3),
('Steel Boots', 'feet', 'feet', 0, 7, 18, 200, 'rare', 5),
('Dragon Scale Boots', 'feet', 'feet', 0, 12, 30, 600, 'epic', 8),
('Void Boots', 'feet', 'feet', 0, 18, 60, 1500, 'legendary', 10)
ON CONFLICT (name) DO NOTHING;
