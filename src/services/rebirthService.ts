import { supabase } from './supabase'

export interface RebirthData {
  rebirthCount: number
  totalRebirthsGoldEarned: number
  rebirthBonusGoldMultiplier: number
  rebirthBonusMergeMultiplier: number
}

export const loadRebirthData = async (userId: string): Promise<RebirthData | null> => {
  const { data, error } = await supabase
    .from('player_rebirths')
    .select('rebirth_count, total_rebirths_gold_earned, rebirth_bonus_gold_multiplier, rebirth_bonus_merge_multiplier')
    .eq('player_id', userId)
    .maybeSingle()

  if (error) {
    console.error('Error loading rebirth data:', error)
    return null
  }

  if (!data) {
    return null
  }

  return {
    rebirthCount: data.rebirth_count,
    totalRebirthsGoldEarned: data.total_rebirths_gold_earned,
    rebirthBonusGoldMultiplier: data.rebirth_bonus_gold_multiplier,
    rebirthBonusMergeMultiplier: data.rebirth_bonus_merge_multiplier
  }
}

export const initializeRebirthData = async (userId: string): Promise<RebirthData> => {
  const { data, error } = await supabase
    .from('player_rebirths')
    .insert([
      {
        player_id: userId,
        rebirth_count: 0,
        total_rebirths_gold_earned: 0,
        rebirth_bonus_gold_multiplier: 1.0,
        rebirth_bonus_merge_multiplier: 1.0
      }
    ])
    .select()
    .single()

  if (error) {
    console.error('Error initializing rebirth data:', error)
    throw error
  }

  return {
    rebirthCount: data.rebirth_count,
    totalRebirthsGoldEarned: data.total_rebirths_gold_earned,
    rebirthBonusGoldMultiplier: data.rebirth_bonus_gold_multiplier,
    rebirthBonusMergeMultiplier: data.rebirth_bonus_merge_multiplier
  }
}

export const performRebirth = async (
  userId: string,
  currentGold: number,
  currentRebirthCount: number
): Promise<RebirthData> => {
  const newRebirthCount = currentRebirthCount + 1
  const goldMultiplier = 1 + newRebirthCount * 0.05
  const mergeMultiplier = 1 + newRebirthCount * 0.05
  const totalGoldEarned = currentGold * 0.05

  const { data, error } = await supabase
    .from('player_rebirths')
    .update({
      rebirth_count: newRebirthCount,
      total_rebirths_gold_earned: totalGoldEarned,
      rebirth_bonus_gold_multiplier: goldMultiplier,
      rebirth_bonus_merge_multiplier: mergeMultiplier,
      updated_at: new Date().toISOString()
    })
    .eq('player_id', userId)
    .select()
    .single()

  if (error) {
    console.error('Error performing rebirth:', error)
    throw error
  }

  return {
    rebirthCount: data.rebirth_count,
    totalRebirthsGoldEarned: data.total_rebirths_gold_earned,
    rebirthBonusGoldMultiplier: data.rebirth_bonus_gold_multiplier,
    rebirthBonusMergeMultiplier: data.rebirth_bonus_merge_multiplier
  }
}

export const resetRebirthData = async (userId: string): Promise<void> => {
  const { error } = await supabase
    .from('player_rebirths')
    .update({
      rebirth_count: 0,
      total_rebirths_gold_earned: 0,
      rebirth_bonus_gold_multiplier: 1.0,
      rebirth_bonus_merge_multiplier: 1.0,
      updated_at: new Date().toISOString()
    })
    .eq('player_id', userId)

  if (error) {
    console.error('Error resetting rebirth data:', error)
    throw error
  }
}
