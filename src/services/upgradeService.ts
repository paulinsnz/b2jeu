import { supabase } from './supabase'

export interface UpgradeState {
  parcelCost: number
  parcelPurchasedCount: number
  levelCosts: Record<number, number>
  chanceLevel: number
  chanceCost: number
  maxLevelUpgrade: number
  maxLevelCost: number
}

export async function loadUpgrades(playerId: string): Promise<UpgradeState | null> {
  try {
    const { data, error } = await supabase
      .from('player_upgrades')
      .select('*')
      .eq('player_id', playerId)
      .maybeSingle()

    if (error) {
      console.error('Error loading upgrades:', error)
      return null
    }

    if (!data) {
      return null
    }

    return {
      parcelCost: data.parcel_cost,
      parcelPurchasedCount: data.parcel_purchased_count,
      levelCosts: {
        1: data.level_1_cost,
        2: data.level_2_cost,
        3: data.level_3_cost,
        4: data.level_4_cost,
        5: data.level_5_cost,
        6: data.level_6_cost,
        7: data.level_7_cost,
        8: data.level_8_cost,
        9: data.level_9_cost,
        10: data.level_10_cost
      },
      chanceLevel: data.chance_level,
      chanceCost: data.chance_cost,
      maxLevelUpgrade: data.max_level_upgrade,
      maxLevelCost: data.max_level_cost
    }
  } catch (err) {
    console.error('Error in loadUpgrades:', err)
    return null
  }
}

export async function saveUpgrades(playerId: string, upgrades: UpgradeState) {
  try {
    const { data: existingData } = await supabase
      .from('player_upgrades')
      .select('id')
      .eq('player_id', playerId)
      .maybeSingle()

    if (existingData) {
      const { error } = await supabase
        .from('player_upgrades')
        .update({
          parcel_cost: upgrades.parcelCost,
          parcel_purchased_count: upgrades.parcelPurchasedCount,
          level_1_cost: upgrades.levelCosts[1],
          level_2_cost: upgrades.levelCosts[2],
          level_3_cost: upgrades.levelCosts[3],
          level_4_cost: upgrades.levelCosts[4],
          level_5_cost: upgrades.levelCosts[5],
          level_6_cost: upgrades.levelCosts[6],
          level_7_cost: upgrades.levelCosts[7],
          level_8_cost: upgrades.levelCosts[8],
          level_9_cost: upgrades.levelCosts[9],
          level_10_cost: upgrades.levelCosts[10],
          chance_level: upgrades.chanceLevel,
          chance_cost: upgrades.chanceCost,
          max_level_upgrade: upgrades.maxLevelUpgrade,
          max_level_cost: upgrades.maxLevelCost,
          updated_at: new Date().toISOString()
        })
        .eq('player_id', playerId)

      if (error) {
        console.error('Error updating upgrades:', error)
        return false
      }
    } else {
      const { error } = await supabase
        .from('player_upgrades')
        .insert({
          player_id: playerId,
          parcel_cost: upgrades.parcelCost,
          parcel_purchased_count: upgrades.parcelPurchasedCount,
          level_1_cost: upgrades.levelCosts[1],
          level_2_cost: upgrades.levelCosts[2],
          level_3_cost: upgrades.levelCosts[3],
          level_4_cost: upgrades.levelCosts[4],
          level_5_cost: upgrades.levelCosts[5],
          level_6_cost: upgrades.levelCosts[6],
          level_7_cost: upgrades.levelCosts[7],
          level_8_cost: upgrades.levelCosts[8],
          level_9_cost: upgrades.levelCosts[9],
          level_10_cost: upgrades.levelCosts[10],
          chance_level: upgrades.chanceLevel,
          chance_cost: upgrades.chanceCost,
          max_level_upgrade: upgrades.maxLevelUpgrade,
          max_level_cost: upgrades.maxLevelCost
        })

      if (error) {
        console.error('Error saving upgrades:', error)
        return false
      }
    }

    return true
  } catch (err) {
    console.error('Error in saveUpgrades:', err)
    return false
  }
}
