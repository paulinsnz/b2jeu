<template>
  <div class="event-overlay" @click.self="close">
    <div class="event-modal">
      <div class="modal-header">
        <h2>Monde d'Evenements</h2>
        <div class="event-currency">
          <span class="currency-icon">🎫</span>
          <span class="currency-amount">{{ eventCurrency }}</span>
        </div>
        <button @click="close" class="close-btn">✕</button>
      </div>

      <div class="event-tabs">
        <button
          @click="activeTab = 'play'"
          :class="{ active: activeTab === 'play' }"
          class="tab-btn"
        >
          Jouer
        </button>
        <button
          @click="activeTab = 'upgrades'"
          :class="{ active: activeTab === 'upgrades' }"
          class="tab-btn"
        >
          Ameliorations
        </button>
      </div>

      <div v-if="activeTab === 'play'" class="event-play">
        <div v-if="!inEventRun" class="event-intro">
          <div class="intro-header">
            <h3>Mode Evenement Infini</h3>
            <span class="badge">Monde Alternatif</span>
          </div>
          <p>Entrez dans un monde parallele et affrontez des vagues d'ennemis de plus en plus difficiles!</p>
          <div class="event-info-cards">
            <div class="info-card">
              <div class="info-icon">🎫</div>
              <div class="info-text">
                <strong>Tickets Evenement</strong>
                <p>Monnaie exclusive au monde d'evenements. Non convertible en or normal.</p>
              </div>
            </div>
            <div class="info-card">
              <div class="info-icon">📈</div>
              <div class="info-text">
                <strong>Multiplicateurs Croissants</strong>
                <p>Chaque vague augmente vos gains de +50%</p>
              </div>
            </div>
            <div class="info-card">
              <div class="info-icon">⭐</div>
              <div class="info-text">
                <strong>Ameliorations Permanentes</strong>
                <p>Depensez vos tickets pour renforcer votre jeu principal</p>
              </div>
            </div>
          </div>
          <button @click="startEventRun" class="start-event-btn">
            Entrer dans l'Evenement
          </button>
        </div>

        <div v-else class="event-active">
          <div class="wave-header">
            <div class="wave-title-section">
              <h3>VAGUE <span class="wave-number">{{ currentWave }}</span></h3>
              <div class="wave-difficulty">
                <span v-for="i in Math.min(currentWave, 5)" :key="i" class="difficulty-star">⭐</span>
              </div>
            </div>
            <div class="wave-stats">
              <div class="stat">
                <span class="stat-label">Tickets Gagnés:</span>
                <span class="stat-value">🎫 {{ Math.floor(eventGold) }}</span>
              </div>
              <div class="stat">
                <span class="stat-label">Fusions:</span>
                <span class="stat-value">{{ eventMerges }}</span>
              </div>
              <div class="stat">
                <span class="stat-label">Boost:</span>
                <span class="stat-value multiplier">x{{ waveMultiplier.toFixed(1) }}</span>
              </div>
            </div>
          </div>

          <div class="event-board">
            <div
              v-for="(cell, index) in eventBoard"
              :key="index"
              class="event-cell"
              :class="{ 'has-item': cell !== null }"
              @drop="handleEventDrop($event, index)"
              @dragover.prevent
              @dragenter.prevent
            >
              <div
                v-if="cell !== null"
                class="event-item"
                :class="`level-${cell}`"
                draggable="true"
                @dragstart="handleEventDragStart($event, index)"
              >
                {{ cell }}
              </div>
            </div>
          </div>

          <div class="event-controls">
            <button @click="addEventItem" class="add-event-btn" :class="{ disabled: eventGold < addEventItemCost }">
              <span class="btn-label">Ajouter Element</span>
              <span class="btn-cost">🎫 {{ addEventItemCost }}</span>
            </button>
            <button @click="nextWave" class="next-wave-btn">
              ▶ Vague Suivante
            </button>
            <button @click="endEventRun" class="end-event-btn">
              Quitter l'Evenement
            </button>
          </div>
        </div>
      </div>

      <div v-if="activeTab === 'upgrades'" class="event-upgrades">
        <h3>Ameliorations Permanentes</h3>
        <p class="upgrades-description">
          Convertissez vos tickets 🎫 en ameliorations permanentes pour votre progression au mode normal. Ces boosts s'appliquent meme en dehors du monde d'evenements!
        </p>

        <div class="upgrades-grid">
          <div
            v-for="upgrade in permanentUpgrades"
            :key="upgrade.id"
            class="upgrade-card"
            :class="{ disabled: eventCurrency < upgrade.cost }"
          >
            <div class="upgrade-icon">{{ upgrade.icon }}</div>
            <div class="upgrade-info">
              <h4>{{ upgrade.name }}</h4>
              <p>{{ upgrade.description }}</p>
              <div class="upgrade-level">
                <span>Niveau: {{ upgrade.level }}</span>
                <span class="upgrade-effect">{{ upgrade.effect }}</span>
              </div>
            </div>
            <div class="upgrade-purchase">
              <div class="upgrade-cost">
                <span class="currency-icon">🎫</span>
                <span>{{ upgrade.cost }}</span>
              </div>
              <button
                @click="buyUpgrade(upgrade)"
                :disabled="eventCurrency < upgrade.cost"
                class="buy-upgrade-btn"
              >
                Ameliorer
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

interface PermanentUpgrade {
  id: string
  name: string
  description: string
  icon: string
  level: number
  cost: number
  effect: string
  type: 'gold' | 'merge' | 'xp'
}

const props = defineProps<{
  eventCurrency: number
}>()

const emit = defineEmits<{
  close: []
  endEventRun: [gold: number, tickets: number]
  buyUpgrade: [upgrade: PermanentUpgrade]
}>()

const activeTab = ref<'play' | 'upgrades'>('play')
const inEventRun = ref(false)
const currentWave = ref(1)
const eventGold = ref(0)
const eventMerges = ref(0)
const eventBoard = ref<(number | null)[]>(Array(16).fill(null))
const draggedEventIndex = ref<number | null>(null)
const addEventItemCost = ref(50)

const permanentUpgrades = ref<PermanentUpgrade[]>([
  {
    id: 'gold-boost',
    name: 'Boost d\'Or',
    description: 'Augmente tous les gains d\'or dans le mode normal',
    icon: '💰',
    level: 1,
    cost: 10,
    effect: '+5% Or',
    type: 'gold'
  },
  {
    id: 'merge-boost',
    name: 'Boost de Fusion',
    description: 'Augmente les gains lors des fusions',
    icon: '🔗',
    level: 1,
    cost: 15,
    effect: '+8% Fusion',
    type: 'merge'
  },
  {
    id: 'xp-boost',
    name: 'Boost d\'XP',
    description: 'Augmente les gains d\'experience',
    icon: '⭐',
    level: 1,
    cost: 12,
    effect: '+6% XP',
    type: 'xp'
  },
  {
    id: 'mega-gold',
    name: 'Mega Or',
    description: 'Gros boost d\'or permanent',
    icon: '💎',
    level: 1,
    cost: 40,
    effect: '+15% Or',
    type: 'gold'
  },
  {
    id: 'super-merge',
    name: 'Super Fusion',
    description: 'Double les gains de fusion',
    icon: '💫',
    level: 1,
    cost: 50,
    effect: '+25% Fusion',
    type: 'merge'
  },
  {
    id: 'xp-master',
    name: 'Maitre XP',
    description: 'Triple les gains d\'experience',
    icon: '🌟',
    level: 1,
    cost: 45,
    effect: '+50% XP',
    type: 'xp'
  }
])

const waveMultiplier = computed(() => {
  return 1 + (currentWave.value - 1) * 0.5
})

const startEventRun = () => {
  inEventRun.value = true
  currentWave.value = 1
  eventGold.value = 0
  eventMerges.value = 0
  eventBoard.value = Array(16).fill(null)
  eventBoard.value[0] = 1
  eventBoard.value[1] = 1
  addEventItemCost.value = 50
}

const addEventItem = () => {
  if (eventGold.value < addEventItemCost.value) {
    return
  }

  const emptyCells = eventBoard.value
    .map((cell, index) => (cell === null ? index : null))
    .filter(index => index !== null) as number[]

  if (emptyCells.length === 0) {
    return
  }

  eventGold.value -= addEventItemCost.value
  addEventItemCost.value = Math.floor(addEventItemCost.value * 1.5)
  const randomIndex = emptyCells[Math.floor(Math.random() * emptyCells.length)]
  const level = Math.min(1 + Math.floor(currentWave.value / 3), 5)
  eventBoard.value[randomIndex] = level
}

const handleEventDragStart = (event: DragEvent, index: number) => {
  draggedEventIndex.value = index
  if (event.dataTransfer) {
    event.dataTransfer.effectAllowed = 'move'
  }
}

const handleEventDrop = (event: DragEvent, targetIndex: number) => {
  event.preventDefault()

  if (draggedEventIndex.value === null || draggedEventIndex.value === targetIndex) {
    draggedEventIndex.value = null
    return
  }

  const sourceValue = eventBoard.value[draggedEventIndex.value]
  const targetValue = eventBoard.value[targetIndex]

  if (targetValue === null) {
    eventBoard.value[targetIndex] = sourceValue
    eventBoard.value[draggedEventIndex.value] = null
  } else if (sourceValue === targetValue) {
    eventBoard.value[targetIndex] = (targetValue || 0) + 1
    eventBoard.value[draggedEventIndex.value] = null

    const goldGained = (targetValue || 0) * 50 * waveMultiplier.value
    eventGold.value += goldGained
    eventMerges.value += 1
  }

  draggedEventIndex.value = null
}

const nextWave = () => {
  currentWave.value += 1
  const waveBonus = currentWave.value * 100 * waveMultiplier.value
  eventGold.value += waveBonus
}

const endEventRun = () => {
  const ticketsEarned = Math.floor(currentWave.value * 2 + eventMerges.value * 0.5)
  emit('endEventRun', 0, ticketsEarned)
  inEventRun.value = false
}

const calculateUpgradeCost = (baseCost: number, level: number): number => {
  return Math.floor(baseCost * Math.pow(1.25, level - 1))
}

const buyUpgrade = (upgrade: PermanentUpgrade) => {
  if (props.eventCurrency >= upgrade.cost) {
    emit('buyUpgrade', upgrade)
    upgrade.level += 1
    upgrade.cost = calculateUpgradeCost(
      upgrade.id === 'gold-boost' ? 10 :
      upgrade.id === 'merge-boost' ? 15 :
      upgrade.id === 'xp-boost' ? 12 :
      upgrade.id === 'mega-gold' ? 40 :
      upgrade.id === 'super-merge' ? 50 : 45,
      upgrade.level
    )
  }
}

const close = () => {
  if (inEventRun.value) {
    const confirm = window.confirm('Voulez-vous vraiment quitter? Votre progression sera perdue!')
    if (!confirm) return
  }
  emit('close')
}
</script>

<style scoped>
.event-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.85);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1500;
  padding: 20px;
}

.event-modal {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  border-radius: 16px;
  max-width: 1000px;
  width: 100%;
  max-height: 95vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
  color: white;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 30px;
  border-bottom: 2px solid #0f3460;
  position: sticky;
  top: 0;
  background: #1a1a2e;
  z-index: 10;
  border-radius: 16px 16px 0 0;
}

.modal-header h2 {
  margin: 0;
  font-size: 2em;
  color: #e94560;
}

.event-currency {
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(233, 69, 96, 0.2);
  padding: 10px 20px;
  border-radius: 8px;
  border: 2px solid #e94560;
}

.currency-icon {
  font-size: 1.5em;
}

.currency-amount {
  font-size: 1.3em;
  font-weight: bold;
  color: #e94560;
}

.close-btn {
  background: none;
  border: none;
  font-size: 2em;
  color: #ecf0f1;
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

.event-tabs {
  display: flex;
  gap: 0;
  background: #0f3460;
}

.tab-btn {
  flex: 1;
  background: transparent;
  color: #95a5a6;
  border: none;
  padding: 15px;
  font-size: 1.1em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  border-bottom: 3px solid transparent;
}

.tab-btn.active {
  color: #e94560;
  border-bottom-color: #e94560;
  background: rgba(233, 69, 96, 0.1);
}

.tab-btn:hover:not(.active) {
  background: rgba(255, 255, 255, 0.05);
}

.event-play,
.event-upgrades {
  padding: 30px;
}

.event-intro {
  text-align: center;
}

.intro-header {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  margin-bottom: 20px;
}

.event-intro h3 {
  font-size: 2.5em;
  margin: 0;
  color: #e94560;
  font-weight: 700;
  letter-spacing: 2px;
}

.badge {
  background: linear-gradient(135deg, #e94560 0%, #c0392b 100%);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.85em;
  font-weight: 600;
}

.event-intro > p {
  font-size: 1.2em;
  color: #95a5a6;
  margin-bottom: 40px;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.event-info-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.info-card {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  gap: 15px;
  align-items: start;
  border: 2px solid rgba(233, 69, 96, 0.3);
  transition: all 0.3s;
}

.info-card:hover {
  transform: translateY(-4px);
  border-color: #e94560;
  box-shadow: 0 8px 20px rgba(233, 69, 96, 0.3);
}

.info-icon {
  font-size: 2.5em;
  flex-shrink: 0;
}

.info-text strong {
  display: block;
  font-size: 1.1em;
  margin-bottom: 8px;
  color: #ecf0f1;
}

.info-text p {
  margin: 0;
  color: #95a5a6;
  font-size: 0.95em;
  line-height: 1.4;
}

.start-event-btn {
  background: linear-gradient(135deg, #e94560 0%, #c0392b 100%);
  color: white;
  border: none;
  padding: 18px 50px;
  border-radius: 12px;
  font-size: 1.4em;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 6px 20px rgba(233, 69, 96, 0.4);
}

.start-event-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(233, 69, 96, 0.6);
}

.wave-header {
  margin-bottom: 30px;
  background: rgba(233, 69, 96, 0.1);
  border: 2px solid #e94560;
  border-radius: 12px;
  padding: 20px;
}

.wave-title-section {
  text-align: center;
  margin-bottom: 15px;
}

.wave-header h3 {
  font-size: 2.5em;
  margin: 0 0 10px 0;
  color: #e94560;
  text-align: center;
  font-weight: 700;
  letter-spacing: 1px;
}

.wave-number {
  background: linear-gradient(135deg, #e94560 0%, #c0392b 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.wave-difficulty {
  text-align: center;
  font-size: 1.5em;
  letter-spacing: 4px;
}

.wave-stats {
  display: flex;
  justify-content: center;
  gap: 40px;
  flex-wrap: wrap;
}

.stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  background: rgba(255, 255, 255, 0.05);
  padding: 12px 25px;
  border-radius: 8px;
  border: 1px solid rgba(233, 69, 96, 0.3);
}

.stat-label {
  font-size: 0.9em;
  color: #95a5a6;
}

.stat-value {
  font-size: 1.4em;
  font-weight: bold;
  color: #ecf0f1;
  margin-top: 4px;
}

.stat-value.multiplier {
  color: #e94560;
}

.event-board {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
  background: rgba(0, 0, 0, 0.3);
  padding: 10px;
  border-radius: 12px;
  margin-bottom: 20px;
}

.event-cell {
  aspect-ratio: 1;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.2s;
  border: 1px solid rgba(233, 69, 96, 0.2);
}

.event-cell.has-item {
  background-color: transparent;
}

.event-item {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2em;
  font-weight: bold;
  border-radius: 8px;
  cursor: grab;
  transition: transform 0.2s, box-shadow 0.2s;
  user-select: none;
}

.event-item:active {
  cursor: grabbing;
}

.event-item:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(233, 69, 96, 0.4);
}

.event-item.level-1 {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.event-item.level-2 {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.event-item.level-3 {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
}

.event-item.level-4 {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  color: white;
}

.event-item.level-5 {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
  color: white;
}

.event-controls {
  display: flex;
  gap: 15px;
  justify-content: center;
  flex-wrap: wrap;
}

.add-event-btn,
.next-wave-btn,
.end-event-btn {
  color: white;
  border: none;
  padding: 14px 28px;
  border-radius: 10px;
  font-size: 1.05em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  min-width: 160px;
}

.btn-label {
  display: block;
}

.btn-cost {
  font-size: 0.9em;
  opacity: 0.9;
}

.add-event-btn {
  background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%);
}

.add-event-btn:hover:not(.disabled) {
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(39, 174, 96, 0.5);
}

.add-event-btn.disabled {
  background: #95a5a6;
  cursor: not-allowed;
  opacity: 0.6;
}

.next-wave-btn {
  background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
}

.next-wave-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(52, 152, 219, 0.5);
}

.end-event-btn {
  background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
}

.end-event-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(231, 76, 60, 0.5);
}

.event-upgrades h3 {
  font-size: 2em;
  margin: 0 0 10px 0;
  color: #e94560;
  text-align: center;
}

.upgrades-description {
  text-align: center;
  color: #95a5a6;
  font-size: 1.1em;
  margin-bottom: 30px;
}

.upgrades-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.upgrade-card {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 15px;
  border: 2px solid rgba(233, 69, 96, 0.3);
  transition: all 0.3s;
}

.upgrade-card:hover:not(.disabled) {
  transform: translateY(-4px);
  border-color: #e94560;
  box-shadow: 0 8px 20px rgba(233, 69, 96, 0.3);
}

.upgrade-card.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.upgrade-icon {
  font-size: 3em;
  text-align: center;
}

.upgrade-info h4 {
  margin: 0 0 8px 0;
  font-size: 1.3em;
  color: #ecf0f1;
}

.upgrade-info p {
  margin: 0 0 12px 0;
  color: #95a5a6;
  font-size: 0.95em;
  line-height: 1.4;
}

.upgrade-level {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.9em;
}

.upgrade-level span:first-child {
  color: #95a5a6;
}

.upgrade-effect {
  color: #e94560;
  font-weight: bold;
}

.upgrade-purchase {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 15px;
  padding-top: 15px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.upgrade-cost {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 1.3em;
  font-weight: bold;
  color: #e94560;
}

.buy-upgrade-btn {
  background: linear-gradient(135deg, #e94560 0%, #c0392b 100%);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  flex-shrink: 0;
}

.buy-upgrade-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(233, 69, 96, 0.4);
}

.buy-upgrade-btn:disabled {
  background: #95a5a6;
  cursor: not-allowed;
}
</style>
