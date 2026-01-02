import { supabase } from './supabase'
import { updateLeaderboardEntry } from './leaderboardService'

export interface GameProgression {
  board: (number | null)[]
  boardSize: number
  score: number
  levelMultipliers: Record<number, number>
  addItemCost: number
  itemsAdded: number
  eventCurrency: number
  permanentGoldMultiplier: number
  permanentMergeMultiplier: number
  permanentXpMultiplier: number
  totalMerges: number
  totalGoldEarned: number
  premiumCurrency: number
  activeBoosts: Record<string, boolean>
  playerLevel: number
  playerXP: number
  usedCodes: string[]
  achievements: any[]
  autoBuyEnabled?: boolean
  chanceLevel?: number
  xpMaxLimit?: number
  maxLevelUpgrade?: number
  currentTheme?: string
}

export async function saveProgression(playerId: string, progression: GameProgression) {
  try {
    const { data: existingData } = await supabase
      .from('player_progression')
      .select('id')
      .eq('player_id', playerId)
      .maybeSingle()

    if (existingData) {
      const { error } = await supabase
        .from('player_progression')
        .update({
          board: progression.board,
          board_size: progression.boardSize,
          score: progression.score,
          level_multipliers: progression.levelMultipliers,
          add_item_cost: progression.addItemCost,
          items_added: progression.itemsAdded,
          event_currency: progression.eventCurrency,
          permanent_gold_multiplier: progression.permanentGoldMultiplier,
          permanent_merge_multiplier: progression.permanentMergeMultiplier,
          permanent_xp_multiplier: progression.permanentXpMultiplier,
          total_merges: progression.totalMerges,
          total_gold_earned: progression.totalGoldEarned,
          premium_currency: progression.premiumCurrency,
          active_boosts: progression.activeBoosts,
          player_level: progression.playerLevel,
          player_xp: progression.playerXP,
          used_codes: progression.usedCodes,
          achievements: progression.achievements,
          auto_buy_enabled: progression.autoBuyEnabled || false,
          chance_level: progression.chanceLevel || 0,
          xp_max_limit: progression.xpMaxLimit || 5,
          max_level_upgrade: progression.maxLevelUpgrade || 5,
          current_theme: progression.currentTheme || 'default',
          updated_at: new Date().toISOString()
        })
        .eq('player_id', playerId)

      if (error) {
        console.error('Error updating progression:', error)
        return false
      }
    } else {
      const { error } = await supabase
        .from('player_progression')
        .insert({
          player_id: playerId,
          board: progression.board,
          board_size: progression.boardSize,
          score: progression.score,
          level_multipliers: progression.levelMultipliers,
          add_item_cost: progression.addItemCost,
          items_added: progression.itemsAdded,
          event_currency: progression.eventCurrency,
          permanent_gold_multiplier: progression.permanentGoldMultiplier,
          permanent_merge_multiplier: progression.permanentMergeMultiplier,
          permanent_xp_multiplier: progression.permanentXpMultiplier,
          total_merges: progression.totalMerges,
          total_gold_earned: progression.totalGoldEarned,
          premium_currency: progression.premiumCurrency,
          active_boosts: progression.activeBoosts,
          player_level: progression.playerLevel,
          player_xp: progression.playerXP,
          used_codes: progression.usedCodes,
          achievements: progression.achievements,
          auto_buy_enabled: progression.autoBuyEnabled || false,
          chance_level: progression.chanceLevel || 0,
          xp_max_limit: progression.xpMaxLimit || 5,
          max_level_upgrade: progression.maxLevelUpgrade || 5,
          current_theme: progression.currentTheme || 'default'
        })

      if (error) {
        console.error('Error saving progression:', error)
        return false
      }
    }

    const { data: playerData } = await supabase
      .from('players')
      .select('player_name')
      .eq('id', playerId)
      .maybeSingle()

    if (playerData?.player_name) {
      await updateLeaderboardEntry(playerId, playerData.player_name, Number(progression.score))
    }

    return true
  } catch (err) {
    console.error('Error in saveProgression:', err)
    return false
  }
}

export async function loadProgression(playerId: string): Promise<GameProgression | null> {
  try {
    const { data, error } = await supabase
      .from('player_progression')
      .select('*')
      .eq('player_id', playerId)
      .maybeSingle()

    if (error) {
      console.error('Error loading progression:', error)
      return null
    }

    if (!data) {
      return null
    }

    return {
      board: data.board || [],
      boardSize: data.board_size || 9,
      score: data.score || 50,
      levelMultipliers: data.level_multipliers || {},
      addItemCost: data.add_item_cost || 10,
      itemsAdded: data.items_added || 0,
      eventCurrency: data.event_currency || 0,
      permanentGoldMultiplier: data.permanent_gold_multiplier || 1,
      permanentMergeMultiplier: data.permanent_merge_multiplier || 1,
      permanentXpMultiplier: data.permanent_xp_multiplier || 1,
      totalMerges: data.total_merges || 0,
      totalGoldEarned: data.total_gold_earned || 50,
      premiumCurrency: data.premium_currency || 0,
      activeBoosts: data.active_boosts || {},
      playerLevel: data.player_level || 1,
      playerXP: data.player_xp || 0,
      usedCodes: data.used_codes || [],
      achievements: data.achievements || [],
      autoBuyEnabled: data.auto_buy_enabled || false,
      chanceLevel: data.chance_level || 0,
      xpMaxLimit: data.xp_max_limit || 5,
      maxLevelUpgrade: data.max_level_upgrade || 5,
      currentTheme: data.current_theme || 'default'
    }
  } catch (err) {
    console.error('Error in loadProgression:', err)
    return null
  }
}

export async function deleteProgression(playerId: string) {
  try {
    const { error } = await supabase
      .from('player_progression')
      .delete()
      .eq('player_id', playerId)

    if (error) {
      console.error('Error deleting progression:', error)
      return false
    }

    return true
  } catch (err) {
    console.error('Error in deleteProgression:', err)
    return false
  }
}
