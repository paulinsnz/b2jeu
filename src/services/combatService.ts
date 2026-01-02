import { supabase } from './supabase'
import type { Equipment } from './equipmentService'

export interface Monster {
  name: string
  health: number
  maxHealth: number
  baseGoldReward: number
  baseXpReward: number
  level: number
  imageUrl: string
  difficulty: number
}

export interface CombatResult {
  monsterDefeated: boolean
  goldEarned: number
  xpEarned: number
  monsterName: string
}

const MONSTERS: Monster[] = [
  {
    name: 'Goku enfant',
    health: 20,
    maxHealth: 20,
    baseGoldReward: 10,
    baseXpReward: 5,
    level: 1,
    difficulty: 1,
    imageUrl: 'https://i0.wp.com/www.swafol.fr/wp-content/uploads/2021/04/04_Kid_Goku.png?resize=600%2C750&ssl=1'
  },
  {
    name: 'Orc',
    health: 35,
    maxHealth: 35,
    baseGoldReward: 25,
    baseXpReward: 12,
    level: 2,
    difficulty: 2,
    imageUrl: 'https://images.unsplash.com/photo-1589652717406-1c69efaf1ff8?w=300&h=300&fit=crop'
  },
  {
    name: 'Skeleton Warrior',
    health: 40,
    maxHealth: 40,
    baseGoldReward: 35,
    baseXpReward: 18,
    level: 2,
    difficulty: 2,
    imageUrl: 'https://images.unsplash.com/photo-1509248961158-e54f6934749c?w=300&h=300&fit=crop'
  },
  {
    name: 'Shadow Beast',
    health: 45,
    maxHealth: 45,
    baseGoldReward: 45,
    baseXpReward: 22,
    level: 3,
    difficulty: 3,
    imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=300&h=300&fit=crop'
  },
  {
    name: 'Troll',
    health: 60,
    maxHealth: 60,
    baseGoldReward: 50,
    baseXpReward: 25,
    level: 3,
    difficulty: 3,
    imageUrl: 'https://images.unsplash.com/photo-1551269901-5c5e14c25df7?w=300&h=300&fit=crop'
  },
  {
    name: 'Dark Wizard',
    health: 70,
    maxHealth: 70,
    baseGoldReward: 65,
    baseXpReward: 35,
    level: 4,
    difficulty: 4,
    imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=300&fit=crop'
  },
  {
    name: 'Dragon Spawn',
    health: 80,
    maxHealth: 80,
    baseGoldReward: 75,
    baseXpReward: 40,
    level: 4,
    difficulty: 4,
    imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=300&h=300&fit=crop'
  },
  {
    name: 'Ice Wraith',
    health: 85,
    maxHealth: 85,
    baseGoldReward: 85,
    baseXpReward: 45,
    level: 5,
    difficulty: 5,
    imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=300&fit=crop'
  },
  {
    name: 'Frost Giant',
    health: 100,
    maxHealth: 100,
    baseGoldReward: 100,
    baseXpReward: 50,
    level: 5,
    difficulty: 5,
    imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=300&h=300&fit=crop'
  },
  {
    name: 'Fire Demon',
    health: 120,
    maxHealth: 120,
    baseGoldReward: 120,
    baseXpReward: 60,
    level: 6,
    difficulty: 6,
    imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop'
  }
]

export function generateRandomMonster(): Monster {
  const monster = MONSTERS[Math.floor(Math.random() * MONSTERS.length)]
  return {
    ...monster,
    health: monster.maxHealth,
  }
}

export function calculateDamage(playerLevel: number): number {
  const baseDamage = 5
  const levelBonus = playerLevel * 2
  const variance = Math.random() * 5
  return Math.floor(baseDamage + levelBonus + variance)
}

export function calculateMonsterDamage(monster: Monster): number {
  const baseDamage = 3
  const levelBonus = monster.level * 1.5
  const variance = Math.random() * 3
  return Math.floor(baseDamage + levelBonus + variance)
}

export async function saveCombatLog(
  playerId: string,
  monsterName: string,
  goldEarned: number,
  xpEarned: number
): Promise<boolean> {
  try {
    const { error } = await supabase
      .from('rpg_combat_logs')
      .insert({
        player_id: playerId,
        monster_name: monsterName,
        gold_earned: goldEarned,
        xp_earned: xpEarned,
      })

    if (error) {
      console.error('Error saving combat log:', error)
      return false
    }

    return true
  } catch (err) {
    console.error('Error in saveCombatLog:', err)
    return false
  }
}

export async function addGold(playerId: string, amount: number): Promise<boolean> {
  try {
    const { data: existingGold } = await supabase
      .from('rpg_gold')
      .select('amount')
      .eq('player_id', playerId)
      .maybeSingle()

    if (existingGold) {
      const { error } = await supabase
        .from('rpg_gold')
        .update({
          amount: (existingGold.amount || 0) + amount,
          updated_at: new Date().toISOString(),
        })
        .eq('player_id', playerId)

      if (error) {
        console.error('Error updating gold:', error)
        return false
      }
    } else {
      const { error } = await supabase
        .from('rpg_gold')
        .insert({
          player_id: playerId,
          amount: amount,
        })

      if (error) {
        console.error('Error inserting gold:', error)
        return false
      }
    }

    return true
  } catch (err) {
    console.error('Error in addGold:', err)
    return false
  }
}

export async function getPlayerGold(playerId: string): Promise<number> {
  try {
    const { data, error } = await supabase
      .from('rpg_gold')
      .select('amount')
      .eq('player_id', playerId)
      .maybeSingle()

    if (error) {
      console.error('Error fetching gold:', error)
      return 0
    }

    return data?.amount || 0
  } catch (err) {
    console.error('Error in getPlayerGold:', err)
    return 0
  }
}

export async function getCombatStats(playerId: string): Promise<{ totalGold: number; monstersDefeated: number }> {
  try {
    const { data, error } = await supabase
      .from('rpg_combat_logs')
      .select('gold_earned')
      .eq('player_id', playerId)

    if (error) {
      console.error('Error fetching combat stats:', error)
      return { totalGold: 0, monstersDefeated: 0 }
    }

    const stats = {
      totalGold: data?.reduce((sum, log) => sum + (log.gold_earned || 0), 0) || 0,
      monstersDefeated: data?.length || 0,
    }

    return stats
  } catch (err) {
    console.error('Error in getCombatStats:', err)
    return { totalGold: 0, monstersDefeated: 0 }
  }
}

export async function generateDrops(monsterName: string, difficulty: number): Promise<Equipment[]> {
  try {
    const { data, error } = await supabase
      .from('rpg_monster_loot')
      .select('equipment_id, drop_rate, rpg_equipment_types(*)')
      .eq('monster_name', monsterName)

    if (error || !data) {
      console.error('Error fetching monster loot:', error)
      return []
    }

    const drops: Equipment[] = []

    for (const loot of data) {
      const baseDropRate = loot.drop_rate
      const difficultyBonus = difficulty * 3
      const effectiveDropRate = baseDropRate + difficultyBonus

      if (Math.random() * 100 < effectiveDropRate) {
        const equipment = loot.rpg_equipment_types as any
        if (equipment) {
          drops.push({
            id: equipment.id,
            name: equipment.name,
            equipment_slot: equipment.equipment_slot,
            damage_bonus: equipment.damage_bonus,
            defense_bonus: equipment.defense_bonus,
            health_bonus: equipment.health_bonus,
            price: equipment.price,
            rarity: equipment.rarity,
            required_level: equipment.required_level
          })
        }
      }
    }

    return drops
  } catch (err) {
    console.error('Error in generateDrops:', err)
    return []
  }
}

export async function addDroppedEquipment(
  playerId: string,
  equipment: Equipment
): Promise<boolean> {
  try {
    const { data: playerEquipment, error: fetchError } = await supabase
      .from('rpg_player_equipment')
      .select('inventory')
      .eq('player_id', playerId)
      .maybeSingle()

    if (fetchError) {
      console.error('Error fetching inventory:', fetchError)
      return false
    }

    const inventory = playerEquipment?.inventory || []
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
    console.error('Error in addDroppedEquipment:', err)
    return false
  }
}
