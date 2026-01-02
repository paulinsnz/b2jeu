<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { getLeaderboard, subscribeToLeaderboard, getPlayerRank } from '../services/leaderboardService'
import { getCurrentUser } from '../services/authService'
import type { LeaderboardEntry } from '../services/leaderboardService'

const leaderboard = ref<LeaderboardEntry[]>([])
const currentUserRank = ref<number | null>(null)
const loading = ref(true)
let unsubscribe: (() => void) | null = null

onMounted(async () => {
  await loadLeaderboard()

  unsubscribe = subscribeToLeaderboard(async (entries) => {
    leaderboard.value = entries
    const user = await getCurrentUser()
    if (user) {
      currentUserRank.value = await getPlayerRank(user.id)
    }
  })
})

onUnmounted(() => {
  if (unsubscribe) {
    unsubscribe()
  }
})

async function loadLeaderboard() {
  loading.value = true
  const entries = await getLeaderboard(5)
  leaderboard.value = entries

  const user = await getCurrentUser()
  if (user) {
    currentUserRank.value = await getPlayerRank(user.id)
  }

  loading.value = false
}

function formatScore(score: number): string {
  return Math.floor(score).toLocaleString()
}

function getMedalEmoji(rank: number): string {
  if (rank === 1) return '🥇'
  if (rank === 2) return '🥈'
  if (rank === 3) return '🥉'
  return ''
}
</script>

<template>
  <div class="leaderboard-container">
    <div class="leaderboard-header">
      <h2>Top 5 Mondial</h2>
    </div>

    <div v-if="loading" class="loading-state">
      Chargement du classement...
    </div>

    <div v-else-if="leaderboard.length === 0" class="empty-state">
      Aucun joueur sur le classement pour le moment
    </div>

    <div v-else class="leaderboard-list">
      <div v-for="(entry, index) in leaderboard.slice(0, 5)" :key="entry.id" class="leaderboard-entry" :class="{ 'top-three': index < 3 }">
        <div class="rank-column">
          <span v-if="getMedalEmoji(entry.rank)" class="medal">{{ getMedalEmoji(entry.rank) }}</span>
          <span v-else class="rank-number">#{{ entry.rank }}</span>
        </div>

        <div class="player-column">
          <span class="player-name">{{ entry.playerName }}</span>
        </div>

        <div class="score-column">
          <span class="score">{{ formatScore(entry.score) }}</span>
          <span class="score-label">or</span>
        </div>
      </div>
    </div>

    <div v-if="currentUserRank" class="your-rank-section">
      <div class="your-rank-divider"></div>
      <div class="your-rank-content">
        <span class="your-rank-label">Votre classement:</span>
        <span class="your-rank-badge">#{{ currentUserRank }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.leaderboard-container {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  margin: 20px 0;
}

.leaderboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  border-bottom: 2px solid #f0f0f0;
  padding-bottom: 15px;
}

.leaderboard-header h2 {
  font-size: 1.8em;
  color: #2c3e50;
  margin: 0;
  font-weight: 700;
}

.your-rank-section {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 2px solid #ecf0f1;
}

.your-rank-divider {
  height: 2px;
  background: linear-gradient(90deg, transparent, #3498db, transparent);
  margin-bottom: 15px;
}

.your-rank-content {
  display: flex;
  align-items: center;
  gap: 12px;
  justify-content: center;
  padding: 15px;
  background: linear-gradient(135deg, rgba(52, 152, 219, 0.05), rgba(52, 152, 219, 0.02));
  border-radius: 8px;
}

.your-rank-label {
  font-size: 1.1em;
  color: #34495e;
  font-weight: 600;
}

.your-rank-badge {
  display: inline-block;
  background: linear-gradient(135deg, #3498db, #2980b9);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 1.2em;
  font-weight: 700;
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
}

.rank-number {
  color: #3498db;
  font-weight: 700;
  font-size: 1.3em;
}

.loading-state {
  text-align: center;
  padding: 40px 20px;
  color: #7f8c8d;
  font-size: 1.1em;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: #95a5a6;
  font-size: 1.1em;
}

.leaderboard-list {
  max-height: 600px;
  overflow-y: auto;
}

.leaderboard-entry {
  display: grid;
  grid-template-columns: 50px 1fr 150px;
  gap: 15px;
  align-items: center;
  padding: 12px 15px;
  border-bottom: 1px solid #ecf0f1;
  transition: background-color 0.2s, transform 0.2s;
}

.leaderboard-entry:hover {
  background-color: #f8f9fa;
  transform: translateX(2px);
}

.leaderboard-entry.top-three {
  background-color: rgba(52, 152, 219, 0.05);
  border-left: 3px solid #3498db;
  padding-left: 12px;
}

.rank-column {
  display: flex;
  justify-content: center;
  align-items: center;
  font-weight: 700;
  color: #2c3e50;
}

.medal {
  font-size: 1.5em;
}

.player-column {
  display: flex;
  align-items: center;
}

.player-name {
  font-size: 1em;
  color: #2c3e50;
  font-weight: 500;
  word-break: break-all;
}

.score-column {
  display: flex;
  align-items: baseline;
  gap: 5px;
  justify-content: flex-end;
}

.score {
  font-size: 1.3em;
  font-weight: 700;
  color: #f39c12;
}

.score-label {
  font-size: 0.8em;
  color: #7f8c8d;
  font-weight: 600;
  margin-left: 2px;
}

@media (max-width: 768px) {
  .leaderboard-container {
    margin: 15px 0;
    padding: 15px;
  }

  .leaderboard-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .leaderboard-header h2 {
    font-size: 1.5em;
  }

  .leaderboard-entry {
    grid-template-columns: 40px 1fr 100px;
    gap: 10px;
    padding: 10px;
  }

  .score {
    font-size: 1.1em;
  }
}
</style>
