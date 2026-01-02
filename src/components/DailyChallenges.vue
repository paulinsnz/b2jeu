<template>
  <div class="challenges-overlay" @click.self="close">
    <div class="challenges-modal">
      <div class="modal-header">
        <h2>Defis Quotidiens</h2>
        <button @click="close" class="close-btn">✕</button>
      </div>

      <div class="time-remaining">
        <span class="timer-icon">⏰</span>
        <span>Reinitialisation dans: {{ timeRemaining }}</span>
      </div>

      <div class="challenges-list">
        <div
          v-for="challenge in challenges"
          :key="challenge.id"
          class="challenge-card"
          :class="{ completed: challenge.completed }"
        >
          <div class="challenge-icon">{{ getChallengeIcon(challenge.type) }}</div>
          <div class="challenge-info">
            <h3>{{ getChallengeTitle(challenge.type) }}</h3>
            <p>{{ getChallengeDescription(challenge.type, challenge.target) }}</p>
            <div class="challenge-progress">
              <div class="progress-bar">
                <div
                  class="progress-fill"
                  :style="{ width: `${Math.min((challenge.progress / challenge.target) * 100, 100)}%` }"
                ></div>
              </div>
              <span class="progress-text">{{ challenge.progress }} / {{ challenge.target }}</span>
            </div>
          </div>
          <div class="challenge-reward">
            <div class="reward-icon">{{ getRewardIcon(challenge.rewardType) }}</div>
            <div class="reward-amount">{{ challenge.rewardAmount }}</div>
            <button
              v-if="challenge.completed && !challenge.claimed"
              @click="claimReward(challenge)"
              class="claim-btn"
            >
              Reclamer
            </button>
            <div v-else-if="challenge.claimed" class="claimed-badge">Reclamee</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue'

interface Challenge {
  id: string
  type: 'merge' | 'gold' | 'level' | 'items'
  target: number
  progress: number
  rewardType: 'gold' | 'premium' | 'event'
  rewardAmount: number
  completed: boolean
  claimed: boolean
}

const props = defineProps<{
  playerProgress: {
    merges: number
    gold: number
    maxLevel: number
    itemsAdded: number
  }
}>()

const emit = defineEmits<{
  close: []
  claimReward: [challenge: Challenge]
}>()

const challenges = ref<Challenge[]>([
  {
    id: '1',
    type: 'merge',
    target: 20,
    progress: 0,
    rewardType: 'gold',
    rewardAmount: 500,
    completed: false,
    claimed: false
  },
  {
    id: '2',
    type: 'gold',
    target: 1000,
    progress: 0,
    rewardType: 'premium',
    rewardAmount: 3,
    completed: false,
    claimed: false
  },
  {
    id: '3',
    type: 'level',
    target: 8,
    progress: 0,
    rewardType: 'event',
    rewardAmount: 100,
    completed: false,
    claimed: false
  },
  {
    id: '4',
    type: 'items',
    target: 15,
    progress: 0,
    rewardType: 'gold',
    rewardAmount: 300,
    completed: false,
    claimed: false
  }
])

const timeRemaining = ref('')
let timerInterval: number | null = null

const updateTimeRemaining = () => {
  const now = new Date()
  const tomorrow = new Date(now)
  tomorrow.setDate(tomorrow.getDate() + 1)
  tomorrow.setHours(0, 0, 0, 0)

  const diff = tomorrow.getTime() - now.getTime()
  const hours = Math.floor(diff / (1000 * 60 * 60))
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
  const seconds = Math.floor((diff % (1000 * 60)) / 1000)

  timeRemaining.value = `${hours}h ${minutes}m ${seconds}s`
}

const updateProgress = () => {
  challenges.value.forEach(challenge => {
    switch (challenge.type) {
      case 'merge':
        challenge.progress = props.playerProgress.merges
        break
      case 'gold':
        challenge.progress = Math.floor(props.playerProgress.gold)
        break
      case 'level':
        challenge.progress = props.playerProgress.maxLevel
        break
      case 'items':
        challenge.progress = props.playerProgress.itemsAdded
        break
    }

    if (challenge.progress >= challenge.target) {
      challenge.completed = true
    }
  })
}

const getChallengeIcon = (type: string) => {
  const icons: Record<string, string> = {
    merge: '🔗',
    gold: '💵',
    level: '🎯',
    items: '➕'
  }
  return icons[type] || '❓'
}

const getChallengeTitle = (type: string) => {
  const titles: Record<string, string> = {
    merge: 'Maitre de la Fusion',
    gold: 'Collecteur d\'Or',
    level: 'Niveau Superieur',
    items: 'Createur Prolifique'
  }
  return titles[type] || 'Defi'
}

const getChallengeDescription = (type: string, target: number) => {
  const descriptions: Record<string, string> = {
    merge: `Effectuer ${target} fusions`,
    gold: `Gagner ${target} pieces d'or`,
    level: `Atteindre le niveau ${target}`,
    items: `Ajouter ${target} elements au plateau`
  }
  return descriptions[type] || `Atteindre ${target}`
}

const getRewardIcon = (type: string) => {
  const icons: Record<string, string> = {
    gold: '💵',
    premium: '💎',
    event: '🎫'
  }
  return icons[type] || '🎁'
}

const claimReward = (challenge: Challenge) => {
  challenge.claimed = true
  emit('claimReward', challenge)
}

const close = () => {
  emit('close')
}

onMounted(() => {
  updateTimeRemaining()
  updateProgress()
  timerInterval = window.setInterval(() => {
    updateTimeRemaining()
    updateProgress()
  }, 1000)
})

onBeforeUnmount(() => {
  if (timerInterval) {
    clearInterval(timerInterval)
  }
})
</script>

<style scoped>
.challenges-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.challenges-modal {
  background: linear-gradient(135deg, #ffffff 0%, #f5f7fa 100%);
  border-radius: 16px;
  max-width: 800px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 30px;
  border-bottom: 2px solid #e1e8ed;
  position: sticky;
  top: 0;
  background: white;
  z-index: 10;
  border-radius: 16px 16px 0 0;
}

.modal-header h2 {
  margin: 0;
  font-size: 2em;
  color: #2c3e50;
}

.close-btn {
  background: none;
  border: none;
  font-size: 2em;
  color: #7f8c8d;
  cursor: pointer;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  transition: all 0.3s;
}

.close-btn:hover {
  background: #e74c3c;
  color: white;
}

.time-remaining {
  background: linear-gradient(135deg, #3498db 0%, #2ecc71 100%);
  color: white;
  padding: 15px 30px;
  text-align: center;
  font-size: 1.2em;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.timer-icon {
  font-size: 1.5em;
}

.challenges-list {
  padding: 30px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.challenge-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  gap: 20px;
  align-items: center;
  border: 2px solid #bdc3c7;
  transition: all 0.3s;
}

.challenge-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
}

.challenge-card.completed {
  border-color: #27ae60;
  background: linear-gradient(135deg, rgba(39, 174, 96, 0.05) 0%, rgba(46, 204, 113, 0.05) 100%);
}

.challenge-icon {
  font-size: 3em;
  flex-shrink: 0;
}

.challenge-info {
  flex-grow: 1;
}

.challenge-info h3 {
  margin: 0 0 8px 0;
  font-size: 1.3em;
  color: #2c3e50;
}

.challenge-info p {
  margin: 0 0 12px 0;
  font-size: 0.95em;
  color: #7f8c8d;
}

.challenge-progress {
  margin-top: 10px;
}

.progress-bar {
  background: #ecf0f1;
  border-radius: 8px;
  height: 10px;
  overflow: hidden;
  margin-bottom: 5px;
}

.progress-fill {
  background: linear-gradient(90deg, #3498db 0%, #2ecc71 100%);
  height: 100%;
  transition: width 0.5s;
  border-radius: 8px;
}

.progress-text {
  font-size: 0.9em;
  color: #7f8c8d;
  font-weight: 600;
}

.challenge-reward {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
  min-width: 100px;
}

.reward-icon {
  font-size: 2.5em;
}

.reward-amount {
  font-size: 1.3em;
  font-weight: bold;
  color: #2c3e50;
}

.claim-btn {
  background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  width: 100%;
}

.claim-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(39, 174, 96, 0.4);
}

.claimed-badge {
  background: #95a5a6;
  color: white;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 0.9em;
  font-weight: 600;
}
</style>
