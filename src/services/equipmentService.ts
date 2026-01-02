import { supabase } from './supabase'

export interface Equipment {
  id: string
  name: string
  equipment_slot: string
  equipment_type?: string
  damage_bonus: number
  defense_bonus: number
  health_bonus: number
  price: number
  rarity: string
  required_level: number
}

export interface PlayerEquipment {
  id: string
  player_id: string
  weapon_id: string | null
  helmet_id: string | null
  chest_id: string | null
  legs_id: string | null
  feet_id: string | null
  accessory1_id: string | null
  accessory2_id: string | null
  inventory: Equipment[]
  created_at: string
  updated_at: string
}

export async function getEquipmentTypes(): Promise<Equipment[]> {
  try {
    const { data, error } = await supabase
      .from('rpg_equipment_types')
      .select('*')

    if (error) {
      console.error('Error fetching equipment types:', error)
      return []
    }

    return data || []
  } catch (err) {
    console.error('Error in getEquipmentTypes:', err)
    return []
  }
}

export async function getPlayerEquipment(playerId: string): Promise<PlayerEquipment | null> {
  try {
    const { data, error } = await supabase
      .from('rpg_player_equipment')
      .select('*')
      .eq('player_id', playerId)
      .maybeSingle()

    if (error) {
      console.error('Error fetching player equipment:', error)
      return null
    }

    if (!data) {
      return await initializePlayerEquipment(playerId)
    }

    return data
  } catch (err) {
    console.error('Error in getPlayerEquipment:', err)
    return null
  }
}

export async function initializePlayerEquipment(playerId: string): Promise<PlayerEquipment | null> {
  try {
    const { data, error } = await supabase
      .from('rpg_player_equipment')
      .insert({
        player_id: playerId,
        inventory: [],
      })
      .select()
      .maybeSingle()

    if (error) {
      console.error('Error initializing player equipment:', error)
      return null
    }

    return data || null
  } catch (err) {
    console.error('Error in initializePlayerEquipment:', err)
    return null
  }
}

export async function buyEquipment(
  playerId: string,
  equipmentId: string,
  playerGold: number
): Promise<boolean> {
  try {
    const equipment = await getEquipmentById(equipmentId)
    if (!equipment || equipment.price > playerGold) {
      return false
    }

    const playerEquipment = await getPlayerEquipment(playerId)
    if (!playerEquipment) {
      return false
    }

    const inventory = playerEquipment.inventory || []
    inventory.push(equipment)

    const { error: updateError } = await supabase
      .from('rpg_player_equipment')
      .update({
        inventory: inventory,
        updated_at: new Date().toISOString(),
      })
      .eq('player_id', playerId)

    if (updateError) {
      console.error('Error updating inventory:', updateError)
      return false
    }

    return true
  } catch (err) {
    console.error('Error in buyEquipment:', err)
    return false
  }
}

export async function equipItem(
  playerId: string,
  equipmentId: string | null,
  slot: 'weapon' | 'helmet' | 'chest' | 'legs' | 'feet' | 'accessory1' | 'accessory2'
): Promise<boolean> {
  try {
    const updateData: any = {}
    updateData[`${slot}_id`] = equipmentId
    updateData['updated_at'] = new Date().toISOString()

    const { error } = await supabase
      .from('rpg_player_equipment')
      .update(updateData)
      .eq('player_id', playerId)

    if (error) {
      console.error('Error equipping item:', error)
      return false
    }

    return true
  } catch (err) {
    console.error('Error in equipItem:', err)
    return false
  }
}

export async function getEquipmentById(equipmentId: string): Promise<Equipment | null> {
  try {
    const { data, error } = await supabase
      .from('rpg_equipment_types')
      .select('*')
      .eq('id', equipmentId)
      .maybeSingle()

    if (error) {
      console.error('Error fetching equipment:', error)
      return null
    }

    return data || null
  } catch (err) {
    console.error('Error in getEquipmentById:', err)
    return null
  }
}

export async function deleteItemFromInventory(
  playerId: string,
  itemId: string
): Promise<boolean> {
  try {
    const playerEquipment = await getPlayerEquipment(playerId)
    if (!playerEquipment) {
      return false
    }

    const inventory = playerEquipment.inventory || []
    const filteredInventory = inventory.filter((item) => item.id !== itemId)

    const { error } = await supabase
      .from('rpg_player_equipment')
      .update({
        inventory: filteredInventory,
        updated_at: new Date().toISOString(),
      })
      .eq('player_id', playerId)

    if (error) {
      console.error('Error deleting item:', error)
      return false
    }

    return true
  } catch (err) {
    console.error('Error in deleteItemFromInventory:', err)
    return false
  }
}

export function calculateEquipmentStats(playerEquipment: PlayerEquipment | null) {
  let totalDamage = 0
  let totalDefense = 0
  let totalHealth = 0

  if (!playerEquipment || !playerEquipment.inventory) {
    return { totalDamage, totalDefense, totalHealth }
  }

  const inventoryMap = new Map(playerEquipment.inventory.map(item => [item.id, item]))

  const slotIds = [
    playerEquipment.weapon_id,
    playerEquipment.helmet_id,
    playerEquipment.chest_id,
    playerEquipment.legs_id,
    playerEquipment.feet_id,
    playerEquipment.accessory1_id,
    playerEquipment.accessory2_id,
  ]

  slotIds.forEach(id => {
    if (id) {
      const item = inventoryMap.get(id)
      if (item) {
        totalDamage += item.damage_bonus || 0
        totalDefense += item.defense_bonus || 0
        totalHealth += item.health_bonus || 0
      }
    }
  })

  return { totalDamage, totalDefense, totalHealth }
}

export interface AutoSellSettings {
  rarity: string
  enabled: boolean
}

export async function getAutoSellSettings(playerId: string): Promise<AutoSellSettings[]> {
  try {
    const { data, error } = await supabase
      .from('rpg_auto_sell_settings')
      .select('rarity, enabled')
      .eq('player_id', playerId)
      .order('rarity')

    if (error) {
      console.error('Error fetching auto-sell settings:', error)
      return []
    }

    return data || []
  } catch (err) {
    console.error('Error in getAutoSellSettings:', err)
    return []
  }
}

export async function updateAutoSellSetting(
  playerId: string,
  rarity: string,
  enabled: boolean
): Promise<boolean> {
  try {
    const { error } = await supabase
      .from('rpg_auto_sell_settings')
      .update({ enabled, updated_at: new Date().toISOString() })
      .eq('player_id', playerId)
      .eq('rarity', rarity)

    if (error) {
      console.error('Error updating auto-sell setting:', error)
      return false
    }

    return true
  } catch (err) {
    console.error('Error in updateAutoSellSetting:', err)
    return false
  }
}

export async function autoSellEquipment(playerId: string): Promise<number> {
  try {
    const playerEquipment = await getPlayerEquipment(playerId)
    if (!playerEquipment || !playerEquipment.inventory) {
      return 0
    }

    const settings = await getAutoSellSettings(playerId)
    const enabledRarities = settings
      .filter(s => s.enabled)
      .map(s => s.rarity)

    if (enabledRarities.length === 0) {
      return 0
    }

    const equippedIds = new Set([
      playerEquipment.weapon_id,
      playerEquipment.helmet_id,
      playerEquipment.chest_id,
      playerEquipment.legs_id,
      playerEquipment.feet_id,
      playerEquipment.accessory1_id,
      playerEquipment.accessory2_id,
    ].filter(Boolean))

    let totalGold = 0
    const itemsToKeep: Equipment[] = []

    for (const item of playerEquipment.inventory) {
      if (enabledRarities.includes(item.rarity) && !equippedIds.has(item.id)) {
        totalGold += item.price
      } else {
        itemsToKeep.push(item)
      }
    }

    if (totalGold > 0) {
      const { error: updateError } = await supabase
        .from('rpg_player_equipment')
        .update({
          inventory: itemsToKeep,
          updated_at: new Date().toISOString(),
        })
        .eq('player_id', playerId)

      if (updateError) {
        console.error('Error updating inventory after auto-sell:', updateError)
        return 0
      }

      await addGold(playerId, totalGold)
    }

    return totalGold
  } catch (err) {
    console.error('Error in autoSellEquipment:', err)
    return 0
  }
}

async function addGold(playerId: string, amount: number): Promise<void> {
  try {
    const { data: playerData } = await supabase
      .from('player_progression')
      .select('gold')
      .eq('player_id', playerId)
      .maybeSingle()

    const currentGold = playerData?.gold || 0

    await supabase
      .from('player_progression')
      .update({
        gold: currentGold + amount,
        updated_at: new Date().toISOString(),
      })
      .eq('player_id', playerId)
  } catch (err) {
    console.error('Error in addGold:', err)
  }
}
