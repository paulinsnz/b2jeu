<template>
  <div class="story-mode-overlay" @click.self="closeStoryMode">
    <div class="story-mode-container">
      <div class="story-header">
        <h2>📖 Mode Histoire - Campagne</h2>
        <button @click="closeStoryMode" class="close-btn">✕</button>
      </div>

      <div v-if="!levelSelected" class="levels-grid">
        <div v-for="level in levels" :key="level.id" :class="['level-card', { locked: isLevelLocked(level.id), completed: isLevelCompleted(level.id) }]" @click="selectLevel(level)">
          <div class="level-number">Niveau {{ level.id }}</div>
          <div class="level-info">
            <p class="level-title">{{ level.title }}</p>
            <p class="level-description">{{ level.description }}</p>
            <div class="level-progress">
              <span v-if="isLevelCompleted(level.id)" class="completed-badge">✓ Complété</span>
              <span v-else-if="isLevelLocked(level.id)" class="locked-badge">🔒 Verrouillé</span>
              <span v-else class="progress-text">{{ getCombatsCompleted(level.id) }}/10 combats</span>
            </div>
          </div>
          <div v-if="!isLevelLocked(level.id)" class="level-difficulty">
            <span v-for="star in level.difficulty" :key="star" class="star">⭐</span>
          </div>
        </div>
      </div>

      <div v-else class="level-combat-area">
        <div class="level-header">
          <div>
            <h3>Niveau {{ selectedLevel?.id }} - {{ selectedLevel?.title }}</h3>
            <p class="combat-counter">Combat {{ currentCombatIndex + 1 }}/10</p>
          </div>
          <button @click="exitLevel" class="back-btn">← Retour</button>
        </div>

        <div class="progress-bar-container">
          <div class="progress-bar">
            <div class="progress-fill" :style="{ width: (currentCombatIndex / 10) * 100 + '%' }"></div>
          </div>
          <span class="progress-text">{{ currentCombatIndex }}/10</span>
        </div>

        <div class="combat-display">
          <div v-if="inLevelCombat" class="combat-section">
            <div class="combat-header">
              <div class="combatant player-side">
                <h4>Vous</h4>
              </div>

              <div class="vs-text">VS</div>

              <div class="combatant monster-side">
                <div v-if="levelCurrentMonster" class="monster-image-container">
                  <img :src="levelCurrentMonster.imageUrl" :alt="levelCurrentMonster.name" class="monster-image" />
                </div>
                <h4>{{ levelCurrentMonster?.name }}</h4>
                <div class="health-bar monster">
                  <div class="health-fill monster-fill" :style="{ width: levelMonsterHealthPercent + '%' }"></div>
                </div>
                <p class="health-text">{{ levelCurrentMonster?.health }} / {{ levelCurrentMonster?.maxHealth }} HP</p>
              </div>
            </div>

            <div v-if="levelCombatEnded && levelCombatWon" class="victory-message">
              <h4>Victoire!</h4>
              <p>+{{ lastLevelRewardGold }} or gagné!</p>
              <p>+{{ lastLevelRewardXp }} XP gagné!</p>
            </div>
          </div>

          <div v-if="currentCombatIndex === 10" class="level-completed">
            <h4>🎉 Niveau Complété!</h4>
            <p>Vous avez complété tous les 10 combats!</p>
            <p class="total-rewards">Or total: +{{ totalLevelRewards.gold }} | XP total: +{{ totalLevelRewards.xp }}</p>
            <button @click="exitLevel" class="continue-btn">Continuer</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { generateRandomMonster, calculateDamage, addGold } from '../services/combatService'
import type { Monster } from '../services/combatService'

interface Level {
  id: number
  title: string
  description: string
  difficulty: number
  monstersDefeated: number
}

const props = defineProps<{
  userId: string
}>()

const emit = defineEmits<{
  close: []
}>()

const levels: Level[] = [
  { id: 1, title: 'Les Débuts', description: 'Affrontez les premiers monstres...', difficulty: 1, monstersDefeated: 0 },
  { id: 2, title: 'Le Terrier des Orcs', description: 'Plongez dans le repaire des créatures...', difficulty: 2, monstersDefeated: 0 },
  { id: 3, title: 'La Forêt Maudite', description: 'Traversez les bois les plus sombres...', difficulty: 3, monstersDefeated: 0 },
  { id: 4, title: 'La Tour du Sorcier', description: 'Escaladez la tour mystérieuse...', difficulty: 4, monstersDefeated: 0 },
  { id: 5, title: 'Le Château de Glace', description: 'Bravez les froids glaciaux...', difficulty: 5, monstersDefeated: 0 },
]

const levelSelected = ref(false)
const selectedLevel = ref<Level | null>(null)
const inLevelCombat = ref(false)
const levelCombatEnded = ref(false)
const levelCombatWon = ref(false)
const currentCombatIndex = ref(0)
const levelCurrentMonster = ref<Monster | null>(null)
const lastLevelRewardGold = ref(0)
const lastLevelRewardXp = ref(0)
const totalLevelRewards = ref({ gold: 0, xp: 0 })
const levelAutoInterval = ref<number | null>(null)
const playerAttackSpeed = ref(1000)
const levelCombatLog = ref<{ combat: number; won: boolean }[]>([])

const levelMonsterHealthPercent = computed(() =>
  levelCurrentMonster.value ? (levelCurrentMonster.value.health / levelCurrentMonster.value.maxHealth) * 100 : 0
)

const isLevelLocked = (levelId: number): boolean => {
  return levelId > 1 && !levels.some(l => l.id === levelId - 1 && isLevelCompleted(levelId - 1))
}

const isLevelCompleted = (levelId: number): boolean => {
  return levels[levelId - 1]?.monstersDefeated === 10
}

const getCombatsCompleted = (levelId: number): number => {
  return levels[levelId - 1]?.monstersDefeated || 0
}

const selectLevel = (level: Level) => {
  if (isLevelLocked(level.id)) return
  selectedLevel.value = level
  levelSelected.value = true
  currentCombatIndex.value = level.monstersDefeated
  levelCombatLog.value = []
  totalLevelRewards.value = { gold: 0, xp: 0 }
  startLevelCombat()
}

const startLevelCombat = () => {
  if (currentCombatIndex.value < 10) {
    levelCurrentMonster.value = generateRandomMonster()
    inLevelCombat.value = true
    levelCombatEnded.value = false
    levelCombatWon.value = false
    startLevelAutoCombat()
  }
}

const startLevelAutoCombat = () => {
  if (levelAutoInterval.value) {
    clearInterval(levelAutoInterval.value)
  }
  levelAutoInterval.value = window.setInterval(async () => {
    if (inLevelCombat.value && !levelCombatEnded.value && levelCurrentMonster.value) {
      await levelPlayerAttack()
    }
  }, playerAttackSpeed.value)
}

const levelPlayerAttack = async () => {
  if (!levelCurrentMonster.value) return

  const damage = calculateDamage(1)
  levelCurrentMonster.value.health -= damage

  if (levelCurrentMonster.value.health <= 0) {
    await endLevelCombat(true)
  }
}

const endLevelCombat = async (won: boolean) => {
  if (!levelCurrentMonster.value || !selectedLevel.value) return

  levelCombatEnded.value = true
  levelCombatWon.value = won

  if (won) {
    const goldReward = levelCurrentMonster.value.baseGoldReward
    const xpReward = levelCurrentMonster.value.baseXpReward

    lastLevelRewardGold.value = goldReward
    lastLevelRewardXp.value = xpReward

    totalLevelRewards.value.gold += goldReward
    totalLevelRewards.value.xp += xpReward

    if (props.userId) {
      await addGold(props.userId, goldReward)
    }

    currentCombatIndex.value++
    levelCombatLog.value.push({ combat: currentCombatIndex.value, won: true })

    if (currentCombatIndex.value < 10) {
      setTimeout(() => resetLevelCombat(), 2000)
    } else {
      selectedLevel.value.monstersDefeated = 10
      if (levelAutoInterval.value) {
        clearInterval(levelAutoInterval.value)
      }
    }
  }
}

const resetLevelCombat = () => {
  levelCombatEnded.value = false
  levelCurrentMonster.value = null
  if (currentCombatIndex.value < 10) {
    setTimeout(() => startLevelCombat(), 500)
  }
}

const exitLevel = () => {
  if (levelAutoInterval.value) {
    clearInterval(levelAutoInterval.value)
  }
  levelSelected.value = false
  selectedLevel.value = null
  currentCombatIndex.value = 0
}

const closeStoryMode = () => {
  if (levelAutoInterval.value) {
    clearInterval(levelAutoInterval.value)
  }
  emit('close')
}
</script>

<style scoped>
.story-mode-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1001;
  padding: 20px;
}

.story-mode-container {
  background: linear-gradient(135deg, #ffffff 0%, #f5f7fa 100%);
  border-radius: 16px;
  padding: 30px;
  max-width: 1000px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 12px 48px rgba(0, 0, 0, 0.4);
}

.story-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  border-bottom: 2px solid #34495e;
  padding-bottom: 15px;
}

.story-header h2 {
  margin: 0;
  font-size: 1.8em;
  color: #2c3e50;
}

.close-btn {
  background: #e74c3c;
  color: white;
  border: none;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  font-size: 1.5em;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.3s;
}

.close-btn:hover {
  background: #c0392b;
}

.levels-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.level-card {
  background: white;
  border: 2px solid #bdc3c7;
  border-radius: 12px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
}

.level-card:not(.locked):hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 24px rgba(52, 152, 219, 0.2);
  border-color: #3498db;
}

.level-card.locked {
  opacity: 0.6;
  cursor: not-allowed;
}

.level-card.completed {
  background: linear-gradient(135deg, #d5f4e6 0%, #a9dfbf 100%);
  border-color: #27ae60;
}

.level-number {
  font-size: 0.9em;
  color: #7f8c8d;
  margin-bottom: 10px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.level-info {
  margin-bottom: 15px;
}

.level-title {
  margin: 0 0 8px 0;
  font-size: 1.2em;
  font-weight: 700;
  color: #2c3e50;
}

.level-description {
  margin: 0;
  font-size: 0.9em;
  color: #7f8c8d;
  line-height: 1.5;
}

.level-progress {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #ecf0f1;
}

.completed-badge,
.locked-badge,
.progress-text {
  font-size: 0.85em;
  font-weight: 600;
  color: #27ae60;
}

.locked-badge {
  color: #e74c3c;
}

.progress-text {
  color: #3498db;
}

.level-difficulty {
  display: flex;
  gap: 4px;
}

.star {
  font-size: 1.2em;
}

.level-combat-area {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.level-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  padding-bottom: 15px;
  border-bottom: 2px solid #34495e;
}

.level-header h3 {
  margin: 0;
  font-size: 1.5em;
  color: #2c3e50;
}

.combat-counter {
  margin: 5px 0 0 0;
  color: #7f8c8d;
  font-size: 0.95em;
}

.back-btn {
  background: #95a5a6;
  color: white;
  border: none;
  padding: 10px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s;
}

.back-btn:hover {
  background: #7f8c8d;
  transform: translateY(-2px);
}

.progress-bar-container {
  display: flex;
  gap: 15px;
  align-items: center;
  margin-bottom: 20px;
}

.progress-bar {
  flex: 1;
  height: 12px;
  background: #ecf0f1;
  border-radius: 6px;
  overflow: hidden;
  border: 1px solid #bdc3c7;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #3498db 0%, #2980b9 100%);
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 0.95em;
  font-weight: 600;
  color: #2c3e50;
  min-width: 35px;
}

.combat-display {
  background: linear-gradient(135deg, #ecf0f1 0%, #d5dbdb 100%);
  border-radius: 12px;
  padding: 20px;
  min-height: 400px;
}

.combat-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.combat-header {
  display: flex;
  align-items: center;
  justify-content: space-around;
  padding: 20px;
  background: white;
  border-radius: 8px;
}

.combatant {
  flex: 1;
  text-align: center;
}

.combatant h4 {
  margin: 0 0 10px 0;
  font-size: 1.2em;
  color: #2c3e50;
}

.player-side {
  font-size: 1.3em;
  font-weight: bold;
}

.vs-text {
  font-size: 1.3em;
  font-weight: bold;
  color: #2c3e50;
  margin: 0 20px;
}

.monster-side {
  text-align: center;
}

.monster-image-container {
  width: 120px;
  height: 120px;
  margin: 0 auto 10px;
  border-radius: 8px;
  overflow: hidden;
  border: 2px solid #e74c3c;
}

.monster-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.health-bar {
  width: 100%;
  height: 20px;
  background: #bdc3c7;
  border-radius: 6px;
  overflow: hidden;
  margin: 8px 0;
  border: 1px solid #34495e;
}

.health-fill {
  height: 100%;
}

.health-fill.monster-fill {
  background: linear-gradient(90deg, #e74c3c 0%, #c0392b 100%);
  transition: width 0.3s ease;
}

.health-text {
  margin: 4px 0 0 0;
  color: #7f8c8d;
  font-size: 0.85em;
}

.victory-message {
  padding: 20px;
  border-radius: 8px;
  text-align: center;
  background: linear-gradient(135deg, #d5f4e6 0%, #a9dfbf 100%);
  border: 2px solid #27ae60;
  color: #27ae60;
}

.victory-message h4 {
  margin: 0 0 10px 0;
  font-size: 1.3em;
}

.victory-message p {
  margin: 5px 0;
  font-weight: 600;
}

.level-completed {
  padding: 30px;
  border-radius: 8px;
  text-align: center;
  background: linear-gradient(135deg, #d5f4e6 0%, #a9dfbf 100%);
  border: 2px solid #27ae60;
  color: #27ae60;
}

.level-completed h4 {
  margin: 0 0 15px 0;
  font-size: 1.5em;
}

.level-completed p {
  margin: 10px 0;
  font-size: 1em;
}

.total-rewards {
  font-weight: 700;
  font-size: 1.1em;
  margin: 15px 0 20px 0;
}

.continue-btn {
  background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.continue-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(39, 174, 96, 0.3);
}

@media (max-width: 768px) {
  .levels-grid {
    grid-template-columns: 1fr;
  }

  .combat-header {
    flex-direction: column;
    gap: 15px;
  }

  .vs-text {
    margin: 10px 0;
  }
}
</style>
