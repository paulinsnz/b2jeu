import { supabase } from './supabase'

export interface LeaderboardEntry {
  id: string
  playerId: string
  playerName: string
  score: number
  rank: number
}

export async function getLeaderboard(limit: number = 5): Promise<LeaderboardEntry[]> {
  try {
    const { data, error } = await supabase
      .from('leaderboard_cache')
      .select('*')
      .order('score', { ascending: false })
      .limit(limit)

    if (error) {
      console.error('Error fetching leaderboard:', error)
      return []
    }

    return (data || []).map((entry, index) => ({
      id: entry.id,
      playerId: entry.player_id,
      playerName: entry.player_name,
      score: Number(entry.score),
      rank: index + 1
    }))
  } catch (err) {
    console.error('Error in getLeaderboard:', err)
    return []
  }
}

export async function updateLeaderboardEntry(playerId: string, playerName: string, score: number) {
  try {
    const { data: existingEntry } = await supabase
      .from('leaderboard_cache')
      .select('id')
      .eq('player_id', playerId)
      .maybeSingle()

    if (existingEntry) {
      const { error } = await supabase
        .from('leaderboard_cache')
        .update({
          score: score,
          player_name: playerName,
          updated_at: new Date().toISOString()
        })
        .eq('player_id', playerId)

      if (error) {
        console.error('Error updating leaderboard entry:', error)
        return false
      }
    } else {
      const { error } = await supabase
        .from('leaderboard_cache')
        .insert({
          player_id: playerId,
          player_name: playerName,
          score: score,
          updated_at: new Date().toISOString()
        })

      if (error) {
        console.error('Error inserting leaderboard entry:', error)
        return false
      }
    }

    return true
  } catch (err) {
    console.error('Error in updateLeaderboardEntry:', err)
    return false
  }
}

export function subscribeToLeaderboard(callback: (entries: LeaderboardEntry[]) => void) {
  const subscription = supabase
    .channel('leaderboard_changes')
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'leaderboard_cache'
      },
      async () => {
        const entries = await getLeaderboard(5)
        callback(entries)
      }
    )
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'player_progression'
      },
      async () => {
        const entries = await getLeaderboard(5)
        callback(entries)
      }
    )
    .subscribe()

  return () => {
    subscription.unsubscribe()
  }
}

export async function getPlayerRank(playerId: string): Promise<number | null> {
  try {
    const { data, error } = await supabase
      .from('leaderboard_cache')
      .select('score')
      .eq('player_id', playerId)
      .maybeSingle()

    if (error || !data) {
      return null
    }

    const { data: higherScores, error: rankError } = await supabase
      .from('leaderboard_cache')
      .select('id', { count: 'exact' })
      .gt('score', data.score)

    if (rankError) {
      return null
    }

    return (higherScores?.length || 0) + 1
  } catch (err) {
    console.error('Error in getPlayerRank:', err)
    return null
  }
}
