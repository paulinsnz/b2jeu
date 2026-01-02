<template>
  <div class="merge-game">
    <div class="game-header">
      <h1>Jeu de Merge</h1>
      <div class="stats">
        <div class="stat-item">
          <span class="stat-label">Argent:</span>
          <span class="stat-value">💵 {{ Math.floor(score) }}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Argent/sec:</span>
          <span class="stat-value gold">💵 {{ goldPerSecond.toFixed(1) }}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Niveau Max:</span>
          <span class="stat-value">{{ maxLevel }}</span>
        </div>
        <div class="stat-item player-level">
          <span class="stat-label">Niveau Joueur:</span>
          <span class="stat-value">{{ playerLevel }}</span>
        </div>
      </div>
      <button @click="() => resetGame()" class="reset-btn">Nouvelle Partie</button>
    </div>

    <div
      class="game-board"
      :style="{
        gridTemplateColumns: `repeat(${gridColumns}, 1fr)`,
        '--board-bg-color': themes[currentTheme].boardBackgroundColor,
        '--cell-bg-color': themes[currentTheme].cellBackgroundColor,
        '--header-color': themes[currentTheme].gameHeaderColor,
        '--stat-item-bg': themes[currentTheme].statItemBackground,
        '--stat-item-border': themes[currentTheme].statItemBorder,
        '--xp-bar-bg': themes[currentTheme].xpBarBackground,
        '--xp-fill-gradient': themes[currentTheme].xpFillGradient
      } as any"
    >
      <div
        v-for="(cell, index) in board"
        :key="index"
        class="cell"
        :class="{ 'has-item': cell !== null }"
        @drop="handleDrop($event, index)"
        @dragover.prevent
        @dragenter.prevent
      >
        <div
          v-if="cell !== null"
          class="item"
          :class="`level-${cell}`"
          draggable="true"
          @dragstart="handleDragStart($event, index)"
          :style="{
            backgroundImage: `url(${getTileImage(cell, currentTheme)})`,
            '--level-number': cell
          } as any"
        >
        </div>
      </div>
    </div>

    <div class="controls">
      <button @click="addRandomItem" class="add-btn" :class="{ disabled: score < addItemCost }">
        Ajouter un élément (💵 {{ addItemCost }})
      </button>
      <button @click="isShopOpen = !isShopOpen" class="shop-toggle-btn">
        {{ isShopOpen ? 'Fermer le Shop' : 'Ouvrir le Shop' }}
      </button>
      <button v-if="activeBoosts['auto-merge']" @click="toggleAutoMerge" class="robot-btn" :class="{ active: robotEnabled }">
        🤖 {{ robotEnabled ? 'Robot fusion Actif' : 'Robot fusion Inactif' }}
      </button>
      <button v-if="activeBoosts['auto-buy']" @click="toggleAutoBuy" class="robot-btn" :class="{ active: autoBuyEnabled }">
        🛒 {{ autoBuyEnabled ? 'Robot achat Actif' : 'Robot achat Inactif' }}
      </button>
      <button @click="isAchievementsOpen = true" class="achievements-btn">
        Achievements
      </button>
      <button @click="isChallengesOpen = true" class="challenges-btn">
        Defis Quotidiens
      </button>
      <button @click="isEventWorldOpen = true" class="event-btn">
        Monde d'Evenements
      </button>
      <button @click="handleRPGWorldClick" class="rpg-world-btn">
        Vers le monde RPG
      </button>
      <button v-if="rebirthCount > 0 || score >= 100" @click="isRebirthOpen = true" class="rebirth-btn">
        🔄 Renassance ({{ rebirthCount }})
      </button>
    </div>

    <div class="xp-bar-container">
      <div class="xp-info">
        <span class="xp-label">XP: {{ playerXP.toFixed(1) }} / {{ xpToNextLevel }}</span>
        <span class="level-label">Niveau {{ playerLevel }}</span>
      </div>
      <div class="xp-bar">
        <div class="xp-fill" :style="{ width: `${(playerXP / xpToNextLevel) * 100}%` }"></div>
      </div>
    </div>

    <Shop
      v-if="isShopOpen"
      :gold="score"
      :currentBoardSize="boardSize"
      :levelMultipliers="levelMultipliers"
      :premiumCurrency="premiumCurrency"
      :activeBoosts="activeBoosts"
      :autoBuyEnabled="autoBuyEnabled"
      :chanceLevel="chanceLevel"
      :maxLevel="playerLevel"
      :parcelCost="parcelCost"
      :levelCosts="levelCosts"
      :chanceCost="chanceCost"
      :maxLevelCost="maxLevelCost"
      @upgradeLevelIncome="handleLevelUpgrade"
      @buyParcels="handleBuyParcels"
      @redeemCode="handleRedeemCode"
      @buyPremiumBoost="handleBuyPremiumBoost"
      @toggleAutoBuy="toggleAutoBuy"
      @upgradeChance="handleUpgradeChance"
      @upgradeMaxLevel="handleUpgradeMaxLevel"
      @close="isShopOpen = false"
    />

    <Achievements
      v-if="isAchievementsOpen"
      :achievements="achievements"
      @close="isAchievementsOpen = false"
    />

    <LootChest
      v-if="showLootChest"
      :level="pendingChestLevel"
      @close="handleChestClaim"
    />

    <DailyChallenges
      v-if="isChallengesOpen"
      :playerProgress="{
        merges: totalMerges,
        gold: totalGoldEarned,
        maxLevel: maxLevel,
        itemsAdded: itemsAdded
      }"
      @close="isChallengesOpen = false"
      @claimReward="handleChallengeReward"
    />

    <EventWorld
      v-if="isEventWorldOpen"
      :eventCurrency="eventCurrency"
      @close="isEventWorldOpen = false"
      @endEventRun="handleEventRunEnd"
      @buyUpgrade="handleBuyPermanentUpgrade"
    />

    <RPGAccessLock
      v-if="isRPGWorldOpen && isRPGAccessLocked"
      :correctCode="rpgCorrectCode"
      @unlocked="handleRPGUnlocked"
    />

    <RPGWorld
      v-if="isRPGWorldOpen && !isRPGAccessLocked && currentUserId"
      :userId="currentUserId"
      @close="isRPGWorldOpen = false"
    />

    <Rebirth
      :isOpen="isRebirthOpen"
      :currentGold="score"
      :rebirthCount="rebirthCount"
      :rebirthBonusGoldMultiplier="rebirthBonusGoldMultiplier"
      :rebirthBonusMergeMultiplier="rebirthBonusMergeMultiplier"
      @close="isRebirthOpen = false"
      @confirm="handleRebirthConfirm"
    />

    <Leaderboard />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import Shop from './Shop.vue'
import Achievements from './Achievements.vue'
import LootChest from './LootChest.vue'
import DailyChallenges from './DailyChallenges.vue'
import EventWorld from './EventWorld.vue'
import RPGWorld from './RPGWorld.vue'
import RPGAccessLock from './RPGAccessLock.vue'
import Rebirth from './Rebirth.vue'
import Leaderboard from './Leaderboard.vue'
import { saveProgression, loadProgression, deleteProgression } from '../services/progressionService'
import { loadUpgrades, saveUpgrades, type UpgradeState } from '../services/upgradeService'
import { getCurrentUser } from '../services/authService'
import { getTileImage } from '../config/tileImages'
import { updateLeaderboardEntry } from '../services/leaderboardService'
import { themes, themeSpecialCodes } from '../config/themes'
import type { ThemeType } from '../config/themes'
import { getTileStats } from '../config/tileScaling'
import { loadRebirthData, initializeRebirthData, performRebirth, resetRebirthData } from '../services/rebirthService'

interface Achievement {
  id: string
  name: string
  description: string
  icon: string
  unlocked: boolean
  current: number
  target: number
}

interface PremiumBoost {
  id: string
  name: string
  description: string
  icon: string
  effect: string
  cost: number
  multiplier?: number
  duration?: number
}

interface Loot {
  icon: string
  name: string
  amount: number | string
  rarity: 'common' | 'rare' | 'epic' | 'legendary'
}

const boardSize = ref(9)
const board = ref<(number | null)[]>(Array(9).fill(null))
const score = ref(0)
const draggedIndex = ref<number | null>(null)
const levelMultipliers = ref<Record<number, number>>({})
const isShopOpen = ref(false)
const isAchievementsOpen = ref(false)
const isChallengesOpen = ref(false)
const isEventWorldOpen = ref(false)
const isRPGWorldOpen = ref(false)
const isRPGAccessLocked = ref(true)
const isRebirthOpen = ref(false)
const rpgCorrectCode = 'paulinlegoat'
const addItemCost = ref(10)
const itemsAdded = ref(0)
const eventCurrency = ref(0)
const permanentGoldMultiplier = ref(1)
const permanentMergeMultiplier = ref(1)
const permanentXpMultiplier = ref(1)
const totalMerges = ref(0)
const totalGoldEarned = ref(0)
const premiumCurrency = ref(0)
const activeBoosts = ref<Record<string, boolean>>({})
const playerLevel = ref(1)
const playerXP = ref(0)
const xpMaxLimit = ref(5)
const maxLevelUpgrade = ref(5)
const showLootChest = ref(false)
const pendingChestLevel = ref(1)
const robotEnabled = ref(true)
const autoBuyEnabled = ref(false)
const chanceLevel = ref(0)
const currentTheme = ref<ThemeType>('default')
const parcelCost = ref(200)
const pendingLevelUps = ref<number[]>([])
let levelUpTimeout: number | null = null
const rebirthCount = ref(0)
const rebirthBonusGoldMultiplier = ref(1)
const rebirthBonusMergeMultiplier = ref(1)
const levelCosts = ref<Record<number, number>>({
  1: 50,
  2: 100,
  3: 150,
  4: 250,
  5: 400,
  6: 600,
  7: 900,
  8: 1300,
  9: 1800,
  10: 2500
})
const chanceCost = ref(100)
const maxLevelCost = ref(500)
const parcelPurchasedCount = ref(0)
let goldGenerationInterval: number | null = null
let autoMergeInterval: number | null = null
let autoBuyInterval: number | null = null
let saveInterval: number | null = null
let currentUserId: string | null = null
let currentPlayerName: string | null = null
let leaderboardUpdateInterval: number | null = null

const validCodes: Record<string, number> = {
  'HUETGOAT': 1000000,
  'MERGE100': 50000,
  'SPECIAL': 15,
  'VIPGOLD': 25
}
const usedCodes = ref<string[]>([])

for (let i = 1; i <= 20; i++) {
  levelMultipliers.value[i] = 1
}

const achievements = ref<Achievement[]>([
  {
    id: 'first-merge',
    name: 'Première Fusion',
    description: 'Effectuer votre première fusion',
    icon: '✨',
    unlocked: false,
    current: 0,
    target: 1
  },
  {
    id: 'merger-10',
    name: 'Apprenti Fusionneur',
    description: 'Effectuer 10 fusions',
    icon: '🔥',
    unlocked: false,
    current: 0,
    target: 10
  },
  {
    id: 'merger-50',
    name: 'Expert Fusionneur',
    description: 'Effectuer 50 fusions',
    icon: '💥',
    unlocked: false,
    current: 0,
    target: 50
  },
  {
    id: 'reach-level-5',
    name: 'Niveau 5',
    description: 'Atteindre le niveau 5',
    icon: '🎯',
    unlocked: false,
    current: 0,
    target: 5
  },
  {
    id: 'reach-level-10',
    name: 'Niveau 10',
    description: 'Atteindre le niveau 10',
    icon: '🏆',
    unlocked: false,
    current: 0,
    target: 10
  },
  {
    id: 'gold-100',
    name: 'Petit Trésor',
    description: 'Gagner 100 💵 au total',
    icon: '💰',
    unlocked: false,
    current: 0,
    target: 100
  },
  {
    id: 'gold-1000',
    name: 'Grand Trésor',
    description: 'Gagner 1000 💵 au total',
    icon: '💎',
    unlocked: false,
    current: 0,
    target: 1000
  },
  {
    id: 'expand-board',
    name: 'Expansion',
    description: 'Acheter des parcelles supplémentaires',
    icon: '🏞️',
    unlocked: false,
    current: 0,
    target: 1
  }
])

const maxLevel = computed(() => {
  return maxLevelUpgrade.value
})

const xpToNextLevel = computed(() => {
  return xpMaxLimit.value * playerLevel.value
})

const gridColumns = computed(() => {
  return Math.ceil(Math.sqrt(boardSize.value))
})

const getAchievementGoldBonus = (): number => {
  const unlockedCount = achievements.value.filter(a => a.unlocked).length
  return 1 + (unlockedCount * 0.01)
}

const goldPerSecond = computed(() => {
  let totalGoldPerSecond = 0

  for (let i = 0; i < board.value.length; i++) {
    const level = board.value[i]
    if (level !== null) {
      const tileStats = getTileStats(level)
      const baseGoldPerSecond = tileStats.revenuePerSec
      const multiplier = levelMultipliers.value[level] || 1
      totalGoldPerSecond += baseGoldPerSecond * multiplier
    }
  }

  if (activeBoosts.value['double-gold']) {
    totalGoldPerSecond *= 2
  }
  if (activeBoosts.value['mega-boost']) {
    totalGoldPerSecond *= 5
  }

  totalGoldPerSecond *= permanentGoldMultiplier.value
  totalGoldPerSecond *= rebirthBonusGoldMultiplier.value
  totalGoldPerSecond *= getAchievementGoldBonus()

  return totalGoldPerSecond
})

const checkAchievements = () => {
  achievements.value.forEach(achievement => {
    if (achievement.unlocked) return

    if (achievement.id === 'first-merge' || achievement.id === 'merger-10' || achievement.id === 'merger-50') {
      achievement.current = totalMerges.value
    } else if (achievement.id === 'reach-level-5' || achievement.id === 'reach-level-10') {
      achievement.current = maxLevel.value
    } else if (achievement.id === 'gold-100' || achievement.id === 'gold-1000') {
      achievement.current = Math.floor(totalGoldEarned.value)
    } else if (achievement.id === 'expand-board') {
      achievement.current = boardSize.value > 9 ? 1 : 0
    }

    if (achievement.current >= achievement.target) {
      achievement.unlocked = true
    }
  })
}

watch([totalMerges, maxLevel, totalGoldEarned, boardSize], () => {
  checkAchievements()
})

const processNextLevelUp = () => {
  if (pendingLevelUps.value.length === 0) {
    levelUpTimeout = null
    return
  }

  const nextLevel = pendingLevelUps.value.shift()
  if (nextLevel !== undefined) {
    playerLevel.value = nextLevel
    pendingChestLevel.value = nextLevel
    showLootChest.value = true

    levelUpTimeout = window.setTimeout(() => {
      showLootChest.value = false
      processNextLevelUp()
    }, 3500)
  }
}

const gainXP = (amount: number) => {
  if (playerLevel.value >= maxLevelUpgrade.value) {
    playerXP.value = 0
    return
  }

  playerXP.value += amount * permanentXpMultiplier.value

  while (playerXP.value >= xpToNextLevel.value && playerLevel.value < maxLevelUpgrade.value) {
    playerXP.value -= xpToNextLevel.value
    const nextLevel = playerLevel.value + 1
    pendingLevelUps.value.push(nextLevel)
  }

  if (playerLevel.value >= maxLevelUpgrade.value) {
    playerXP.value = 0
  }

  if (pendingLevelUps.value.length > 0 && !levelUpTimeout) {
    processNextLevelUp()
  }
}

const startGoldGeneration = () => {
  if (goldGenerationInterval) {
    clearInterval(goldGenerationInterval)
  }

  goldGenerationInterval = window.setInterval(() => {
    const goldToAdd = goldPerSecond.value / 10
    score.value += goldToAdd
    totalGoldEarned.value += goldToAdd
    gainXP(0.1)
  }, 100)
}

const getItemRarity = (): number => {
  const rand = Math.random()
  const chanceBoost = chanceLevel.value * 0.05

  const level1Chance = Math.max(0, 1.0 - chanceBoost)
  const level2Chance = Math.min(0.20, chanceBoost * 0.4)
  const level3Chance = Math.min(0.12, chanceBoost * 0.24)
  const level4Chance = Math.min(0.06, chanceBoost * 0.12)

  const level1Max = level1Chance
  const level2Max = level1Max + level2Chance
  const level3Max = level2Max + level3Chance
  const level4Max = level3Max + level4Chance

  if (rand < level1Max) return 1
  if (rand < level2Max) return 2
  if (rand < level3Max) return 3
  if (rand < level4Max) return 4
  return 5
}

const addRandomItem = async () => {
  if (score.value < addItemCost.value) {
    alert(`Pas assez d'argent ! Il vous faut ${addItemCost.value} 💵`)
    return
  }

  const emptyCells = board.value
    .map((cell, index) => (cell === null ? index : null))
    .filter(index => index !== null) as number[]

  if (emptyCells.length === 0) {
    alert('Plus de place ! Fusionnez des éléments.')
    return
  }

  score.value -= addItemCost.value
  addItemCost.value = Math.floor(addItemCost.value * 1.5)
  const randomIndex = emptyCells[Math.floor(Math.random() * emptyCells.length)]
  const itemLevel = getItemRarity()
  board.value[randomIndex] = itemLevel
  itemsAdded.value += 1

  if (currentUserId) {
    const progression = getCurrentProgression()
    await saveProgression(currentUserId, progression)
  }
}

const handleDragStart = (event: DragEvent, index: number) => {
  draggedIndex.value = index
  if (event.dataTransfer) {
    event.dataTransfer.effectAllowed = 'move'
  }
}

const handleDrop = async (event: DragEvent, targetIndex: number) => {
  event.preventDefault()

  if (draggedIndex.value === null || draggedIndex.value === targetIndex) {
    draggedIndex.value = null
    return
  }

  const sourceValue = board.value[draggedIndex.value]
  const targetValue = board.value[targetIndex]

  if (targetValue === null) {
    board.value[targetIndex] = sourceValue
    board.value[draggedIndex.value] = null
  } else if (sourceValue === targetValue) {
    board.value[targetIndex] = (targetValue || 0) + 1
    board.value[draggedIndex.value] = null
    let goldGained = (targetValue || 0) * 5

    if (activeBoosts.value['triple-merge']) {
      goldGained *= 3
    }
    if (activeBoosts.value['mega-boost']) {
      goldGained *= 5
    }

    goldGained *= permanentMergeMultiplier.value
    goldGained *= rebirthBonusMergeMultiplier.value
    goldGained *= getAchievementGoldBonus()

    score.value += goldGained
    totalGoldEarned.value += goldGained
    totalMerges.value += 1
    gainXP((targetValue || 0) * 2 * permanentXpMultiplier.value)

    if (currentUserId) {
      const progression = getCurrentProgression()
      await saveProgression(currentUserId, progression)
    }
  }

  draggedIndex.value = null
}

const toggleAutoMerge = () => {
  robotEnabled.value = !robotEnabled.value
}

const toggleAutoBuy = () => {
  autoBuyEnabled.value = !autoBuyEnabled.value

  if (autoBuyEnabled.value) {
    startAutoBuy()
  } else {
    stopAutoBuy()
  }
}

const performAutoBuy = async () => {
  if (!autoBuyEnabled.value) return

  const emptyCells = board.value
    .map((cell, index) => (cell === null ? index : null))
    .filter(index => index !== null) as number[]

  if (emptyCells.length === 0) return

  if (score.value >= addItemCost.value) {
    score.value -= addItemCost.value
    addItemCost.value = Math.floor(addItemCost.value * 1.5)
    const randomIndex = emptyCells[Math.floor(Math.random() * emptyCells.length)]
    const itemLevel = getItemRarity()
    board.value[randomIndex] = itemLevel
    itemsAdded.value += 1

    if (currentUserId) {
      const progression = getCurrentProgression()
      await saveProgression(currentUserId, progression)
    }
  }
}

const startAutoBuy = () => {
  if (autoBuyInterval) {
    clearInterval(autoBuyInterval)
  }

  autoBuyInterval = window.setInterval(() => {
    performAutoBuy()
  }, 1000)
}

const stopAutoBuy = () => {
  if (autoBuyInterval) {
    clearInterval(autoBuyInterval)
    autoBuyInterval = null
  }
}

const performAutoMerge = () => {
  if (!activeBoosts.value['auto-merge'] || !robotEnabled.value) return

  const mergeMap = new Map<number, number[]>()

  for (let i = 0; i < board.value.length; i++) {
    const level = board.value[i]
    if (level !== null) {
      if (!mergeMap.has(level)) {
        mergeMap.set(level, [])
      }
      mergeMap.get(level)!.push(i)
    }
  }

  for (const [level, indices] of mergeMap.entries()) {
    if (indices.length >= 2) {
      const targetIndex = indices[0]
      const sourceIndex = indices[1]

      board.value[targetIndex] = level + 1
      board.value[sourceIndex] = null

      let goldGained = level * 5

      if (activeBoosts.value['triple-merge']) {
        goldGained *= 3
      }
      if (activeBoosts.value['mega-boost']) {
        goldGained *= 5
      }

      score.value += goldGained
      totalGoldEarned.value += goldGained
      totalMerges.value += 1
      gainXP(level * 2)

      break
    }
  }
}

const handleLevelUpgrade = async (level: number) => {
  const cost = levelCosts.value[level]

  if (score.value >= cost) {
    score.value -= cost
    const currentMultiplier = levelMultipliers.value[level] || 1
    levelMultipliers.value[level] = currentMultiplier + 0.5
    levelCosts.value[level] = Math.floor(levelCosts.value[level] * 1.5)

    if (currentUserId) {
      const progression = getCurrentProgression()
      const upgrades: UpgradeState = {
        parcelCost: parcelCost.value,
        parcelPurchasedCount: parcelPurchasedCount.value,
        levelCosts: levelCosts.value,
        chanceLevel: chanceLevel.value,
        chanceCost: chanceCost.value,
        maxLevelUpgrade: maxLevelUpgrade.value,
        maxLevelCost: maxLevelCost.value
      }
      await saveProgression(currentUserId, progression)
      await saveUpgrades(currentUserId, upgrades)
    }
  }
}

const handleUpgradeChance = async () => {
  const cost = chanceCost.value

  if (score.value >= cost) {
    score.value -= cost
    chanceLevel.value += 1
    chanceCost.value = Math.floor(chanceCost.value * 1.5)

    if (currentUserId) {
      const progression = getCurrentProgression()
      const upgrades: UpgradeState = {
        parcelCost: parcelCost.value,
        parcelPurchasedCount: parcelPurchasedCount.value,
        levelCosts: levelCosts.value,
        chanceLevel: chanceLevel.value,
        chanceCost: chanceCost.value,
        maxLevelUpgrade: maxLevelUpgrade.value,
        maxLevelCost: maxLevelCost.value
      }
      await saveProgression(currentUserId, progression)
      await saveUpgrades(currentUserId, upgrades)
    }
  }
}

const handleUpgradeMaxLevel = async () => {
  const cost = maxLevelCost.value

  if (score.value >= cost) {
    score.value -= cost
    playerLevel.value += 1
    maxLevelCost.value = Math.floor(maxLevelCost.value * 1.5)

    if (currentUserId) {
      const progression = getCurrentProgression()
      const upgrades: UpgradeState = {
        parcelCost: parcelCost.value,
        parcelPurchasedCount: parcelPurchasedCount.value,
        levelCosts: levelCosts.value,
        chanceLevel: chanceLevel.value,
        chanceCost: chanceCost.value,
        maxLevelUpgrade: maxLevelUpgrade.value,
        maxLevelCost: maxLevelCost.value
      }
      await saveProgression(currentUserId, progression)
      await saveUpgrades(currentUserId, upgrades)
    }
  }
}

const handleBuyParcels = async () => {
  const cost = parcelCost.value

  if (score.value >= cost) {
    score.value -= cost
    boardSize.value += 4
    parcelPurchasedCount.value += 1
    parcelCost.value = Math.floor(parcelCost.value * 2)

    const newBoard = Array(boardSize.value).fill(null)
    for (let i = 0; i < board.value.length; i++) {
      newBoard[i] = board.value[i]
    }
    board.value = newBoard

    if (currentUserId) {
      const progression = getCurrentProgression()
      const upgrades: UpgradeState = {
        parcelCost: parcelCost.value,
        parcelPurchasedCount: parcelPurchasedCount.value,
        levelCosts: levelCosts.value,
        chanceLevel: chanceLevel.value,
        chanceCost: chanceCost.value,
        maxLevelUpgrade: maxLevelUpgrade.value,
        maxLevelCost: maxLevelCost.value
      }
      await saveProgression(currentUserId, progression)
      await saveUpgrades(currentUserId, upgrades)
    }
  }
}

const handleRedeemCode = (code: string) => {
  const upperCode = code.toUpperCase()

  if (themeSpecialCodes[upperCode]) {
    const newTheme = themeSpecialCodes[upperCode]
    currentTheme.value = newTheme
    const themeName = themes[newTheme].name
    alert(`Thème changé en ${themeName}!`)
    return
  }

  if (usedCodes.value.includes(upperCode)) {
    alert('Ce code a déjà été utilisé!')
    return
  }

  if (validCodes[upperCode]) {
    const reward = validCodes[upperCode]
    if (upperCode === 'HUETGOAT') {
      score.value += reward
      totalGoldEarned.value += reward
      alert(`Code validé! Vous avez reçu ${reward} 💵`)
    } else {
      premiumCurrency.value += reward
      alert(`Code validé! Vous avez reçu ${reward} gemmes premium 💎`)
    }
    usedCodes.value.push(upperCode)
  } else {
    alert('Code invalide!')
  }
}

const handleBuyPremiumBoost = (boost: PremiumBoost) => {
  if (premiumCurrency.value >= boost.cost && !activeBoosts.value[boost.id]) {
    premiumCurrency.value -= boost.cost
    activeBoosts.value[boost.id] = true

    if (boost.id === 'auto-merge') {
      startAutoMerge()
    }
  }
}

const startAutoMerge = () => {
  if (autoMergeInterval) {
    clearInterval(autoMergeInterval)
  }

  autoMergeInterval = window.setInterval(() => {
    performAutoMerge()
  }, 2000)
}

const handleChestClaim = (loots: Loot[]) => {
  loots.forEach(loot => {
    if (loot.name === 'Or' && typeof loot.amount === 'number') {
      score.value += loot.amount
      totalGoldEarned.value += loot.amount
    } else if (loot.name === 'Gemmes Premium' && typeof loot.amount === 'number') {
      premiumCurrency.value += loot.amount
    } else if (loot.name === 'Points XP' && typeof loot.amount === 'number') {
      gainXP(loot.amount)
    } else if (loot.name === 'Élément Niveau 3' || loot.name === 'Élément Niveau 5' || loot.name === 'Élément Niveau 8') {
      const level = parseInt(loot.name.match(/\d+/)?.[0] || '1')
      const emptyCells = board.value
        .map((cell, index) => (cell === null ? index : null))
        .filter(index => index !== null) as number[]

      if (emptyCells.length > 0) {
        const randomIndex = emptyCells[Math.floor(Math.random() * emptyCells.length)]
        board.value[randomIndex] = level
      }
    } else if (loot.name === 'Multiplicateur x2') {
      activeBoosts.value['double-gold'] = true

      setTimeout(() => {
        activeBoosts.value['double-gold'] = false
      }, 3600000)
    } else if (loot.name === 'Super Bonus' && typeof loot.amount === 'number') {
      score.value += loot.amount
      totalGoldEarned.value += loot.amount
    }
  })

  showLootChest.value = false
}

const handleChallengeReward = (challenge: any) => {
  if (challenge.rewardType === 'gold') {
    score.value += challenge.rewardAmount
    totalGoldEarned.value += challenge.rewardAmount
  } else if (challenge.rewardType === 'premium') {
    premiumCurrency.value += challenge.rewardAmount
  } else if (challenge.rewardType === 'event') {
    eventCurrency.value += challenge.rewardAmount
  }
}

const handleEventRunEnd = (gold: number, tickets: number) => {
  score.value += gold
  totalGoldEarned.value += gold
  eventCurrency.value += tickets
}

const handleBuyPermanentUpgrade = async (upgrade: any) => {
  if (eventCurrency.value >= upgrade.cost) {
    eventCurrency.value -= upgrade.cost

    if (upgrade.type === 'gold') {
      const boost = upgrade.level === 1 ? 0.1 : (upgrade.level === 2 ? 0.15 : 0.25)
      permanentGoldMultiplier.value += boost
    } else if (upgrade.type === 'merge') {
      const boost = upgrade.level === 1 ? 0.15 : (upgrade.level === 2 ? 0.2 : 0.5)
      permanentMergeMultiplier.value += boost
    } else if (upgrade.type === 'xp') {
      const boost = upgrade.level === 1 ? 0.12 : (upgrade.level === 2 ? 0.18 : 1)
      permanentXpMultiplier.value += boost
    }

    if (currentUserId) {
      const progression = getCurrentProgression()
      await saveProgression(currentUserId, progression)
    }
  }
}

const getCurrentProgression = () => ({
  board: board.value,
  boardSize: boardSize.value,
  score: score.value,
  levelMultipliers: levelMultipliers.value,
  addItemCost: addItemCost.value,
  itemsAdded: itemsAdded.value,
  eventCurrency: eventCurrency.value,
  permanentGoldMultiplier: permanentGoldMultiplier.value,
  permanentMergeMultiplier: permanentMergeMultiplier.value,
  permanentXpMultiplier: permanentXpMultiplier.value,
  totalMerges: totalMerges.value,
  totalGoldEarned: totalGoldEarned.value,
  premiumCurrency: premiumCurrency.value,
  activeBoosts: activeBoosts.value,
  playerLevel: playerLevel.value,
  playerXP: playerXP.value,
  usedCodes: usedCodes.value,
  achievements: achievements.value,
  autoBuyEnabled: autoBuyEnabled.value,
  chanceLevel: chanceLevel.value,
  xpMaxLimit: xpMaxLimit.value,
  maxLevelUpgrade: maxLevelUpgrade.value,
  currentTheme: currentTheme.value
})

const startAutoSave = () => {
  if (saveInterval) {
    clearInterval(saveInterval)
  }

  saveInterval = window.setInterval(async () => {
    if (currentUserId) {
      const progression = getCurrentProgression()
      await saveProgression(currentUserId, progression)
    }
  }, 30000)
}

const startLeaderboardUpdate = () => {
  if (leaderboardUpdateInterval) {
    clearInterval(leaderboardUpdateInterval)
  }

  leaderboardUpdateInterval = window.setInterval(async () => {
    if (currentUserId && currentPlayerName) {
      await updateLeaderboardEntry(currentUserId, currentPlayerName, score.value)
    }
  }, 5000)
}

const loadGameProgress = async (userId: string) => {
  currentUserId = userId
  const user = await getCurrentUser()
  if (user?.email) {
    currentPlayerName = user.email
  }

  const progression = await loadProgression(userId)
  const upgrades = await loadUpgrades(userId)
  let rebirthData = await loadRebirthData(userId)

  if (!rebirthData) {
    rebirthData = await initializeRebirthData(userId)
  }

  if (rebirthData) {
    rebirthCount.value = rebirthData.rebirthCount
    rebirthBonusGoldMultiplier.value = rebirthData.rebirthBonusGoldMultiplier
    rebirthBonusMergeMultiplier.value = rebirthData.rebirthBonusMergeMultiplier
  }

  if (progression) {
    boardSize.value = progression.boardSize || 9
    board.value = progression.board || Array(9).fill(null)
    score.value = progression.score || 50
    levelMultipliers.value = progression.levelMultipliers || {}
    addItemCost.value = progression.addItemCost || 10
    itemsAdded.value = progression.itemsAdded || 0
    eventCurrency.value = progression.eventCurrency || 0
    permanentGoldMultiplier.value = progression.permanentGoldMultiplier || 1
    permanentMergeMultiplier.value = progression.permanentMergeMultiplier || 1
    permanentXpMultiplier.value = progression.permanentXpMultiplier || 1
    totalMerges.value = progression.totalMerges || 0
    totalGoldEarned.value = progression.totalGoldEarned || 50
    premiumCurrency.value = progression.premiumCurrency || 0
    activeBoosts.value = progression.activeBoosts || {}
    playerLevel.value = progression.playerLevel || 1
    playerXP.value = progression.playerXP || 0
    usedCodes.value = progression.usedCodes || []

    if (progression.achievements && progression.achievements.length > 0) {
      achievements.value = progression.achievements
    }

    if (activeBoosts.value['auto-merge']) {
      startAutoMerge()
    }

    autoBuyEnabled.value = progression.autoBuyEnabled || false
    if (autoBuyEnabled.value) {
      startAutoBuy()
    }
    chanceLevel.value = progression.chanceLevel || 0
    xpMaxLimit.value = progression.xpMaxLimit || 5
    maxLevelUpgrade.value = progression.maxLevelUpgrade || 5
    currentTheme.value = (progression.currentTheme as ThemeType) || 'default'
  } else {
    resetGame()
  }

  if (upgrades) {
    parcelCost.value = upgrades.parcelCost
    parcelPurchasedCount.value = upgrades.parcelPurchasedCount
    levelCosts.value = upgrades.levelCosts
    chanceLevel.value = upgrades.chanceLevel
    chanceCost.value = upgrades.chanceCost
    maxLevelUpgrade.value = upgrades.maxLevelUpgrade
    maxLevelCost.value = upgrades.maxLevelCost
  }

  startAutoSave()
  startLeaderboardUpdate()
}

const handleRPGWorldClick = () => {
  isRPGWorldOpen.value = true
  isRPGAccessLocked.value = true
}

const handleRPGUnlocked = () => {
  isRPGAccessLocked.value = false
}

const handleRebirthConfirm = async () => {
  if (!currentUserId) return

  const rebirthBonus = Math.floor(score.value * 0.05)

  try {
    const rebirthData = await performRebirth(currentUserId, score.value, rebirthCount.value)
    rebirthCount.value = rebirthData.rebirthCount
    rebirthBonusGoldMultiplier.value = rebirthData.rebirthBonusGoldMultiplier
    rebirthBonusMergeMultiplier.value = rebirthData.rebirthBonusMergeMultiplier

    resetGame(true)

    score.value = rebirthBonus
    totalGoldEarned.value = rebirthBonus

    const progression = getCurrentProgression()
    await saveProgression(currentUserId, progression)
  } catch (error) {
    console.error('Error performing rebirth:', error)
    alert('Une erreur est survenue lors de la renassance.')
  }

  isRebirthOpen.value = false
}

const resetAllUpgrades = () => {
  for (let i = 1; i <= 20; i++) {
    levelMultipliers.value[i] = 1
  }
  parcelPurchasedCount.value = 0
  chanceLevel.value = 0
  maxLevelUpgrade.value = 5
  activeBoosts.value = {}
  autoBuyEnabled.value = false
  levelCosts.value = {
    1: 50,
    2: 100,
    3: 150,
    4: 250,
    5: 400,
    6: 600,
    7: 900,
    8: 1300,
    9: 1800,
    10: 2500
  }
  chanceCost.value = 100
  maxLevelCost.value = 500
  parcelCost.value = 200
}

const resetGame = async (isRebirth: boolean = false) => {
  if (!isRebirth) {
    const confirmed = confirm('Êtes-vous sûr de vouloir recommencer une nouvelle partie ? Toute votre progression sera perdue.')

    if (!confirmed) {
      return
    }
  }

  if (goldGenerationInterval) {
    clearInterval(goldGenerationInterval)
  }
  if (autoMergeInterval) {
    clearInterval(autoMergeInterval)
  }
  if (autoBuyInterval) {
    clearInterval(autoBuyInterval)
  }
  if (saveInterval) {
    clearInterval(saveInterval)
  }
  if (leaderboardUpdateInterval) {
    clearInterval(leaderboardUpdateInterval)
  }
  if (levelUpTimeout) {
    clearTimeout(levelUpTimeout)
  }

  if (currentUserId && !isRebirth) {
    await deleteProgression(currentUserId)
    await resetRebirthData(currentUserId)
  }

  boardSize.value = 9
  board.value = Array(9).fill(null)
  score.value = 0
  addItemCost.value = 10
  isShopOpen.value = false
  isAchievementsOpen.value = false
  isChallengesOpen.value = false
  isEventWorldOpen.value = false
  isRPGWorldOpen.value = false
  totalMerges.value = 0
  itemsAdded.value = 0
  totalGoldEarned.value = 0
  premiumCurrency.value = 0
  playerLevel.value = 1
  playerXP.value = 0
  xpMaxLimit.value = 5
  usedCodes.value = []
  showLootChest.value = false
  pendingLevelUps.value = []
  eventCurrency.value = 0
  currentTheme.value = 'default'
  if (!isRebirth) {
    permanentGoldMultiplier.value = 1
    permanentMergeMultiplier.value = 1
    permanentXpMultiplier.value = 1
    rebirthCount.value = 0
    rebirthBonusGoldMultiplier.value = 1
    rebirthBonusMergeMultiplier.value = 1
  }

  resetAllUpgrades()

  achievements.value.forEach(a => {
    a.unlocked = false
    a.current = 0
  })
  board.value[0] = 1
  board.value[1] = 1
  startGoldGeneration()
}

onMounted(async () => {
  const user = await getCurrentUser()
  if (user) {
    await loadGameProgress(user.id)
    startGoldGeneration()
  } else {
    resetGame()
  }
})

onBeforeUnmount(async () => {
  if (goldGenerationInterval) {
    clearInterval(goldGenerationInterval)
  }
  if (autoMergeInterval) {
    clearInterval(autoMergeInterval)
  }
  if (autoBuyInterval) {
    clearInterval(autoBuyInterval)
  }
  if (saveInterval) {
    clearInterval(saveInterval)
  }
  if (leaderboardUpdateInterval) {
    clearInterval(leaderboardUpdateInterval)
  }
  if (levelUpTimeout) {
    clearTimeout(levelUpTimeout)
  }

  if (currentUserId) {
    const progression = getCurrentProgression()
    await saveProgression(currentUserId, progression)
  }
})
</script>

<style scoped>
.merge-game {
  width: 100%;
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
}

.game-header {
  text-align: center;
  margin-bottom: 30px;
}

.game-header h1 {
  margin: 0 0 20px 0;
  font-size: 2.5em;
  color: #2c3e50;
}

.stats {
  display: flex;
  justify-content: center;
  gap: 30px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  background: var(--stat-item-bg, rgba(52, 152, 219, 0.1));
  padding: 12px 20px;
  border-radius: 8px;
  border: 1px solid var(--stat-item-border, #3498db);
}

.stat-label {
  font-size: 0.9em;
  color: #7f8c8d;
  font-weight: 500;
}

.stat-value {
  font-size: 1.5em;
  font-weight: bold;
  color: #2c3e50;
  margin-top: 4px;
}

.stat-value.gold {
  color: #f39c12;
}

.reset-btn {
  background-color: #3498db;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-size: 1em;
  cursor: pointer;
  transition: background-color 0.3s;
}

.reset-btn:hover {
  background-color: #2980b9;
}

.game-board {
  display: grid;
  gap: 10px;
  background-color: var(--board-bg-color, #bdc3c7);
  padding: 10px;
  border-radius: 12px;
  margin-bottom: 20px;
  transition: all 0.5s;
}

.cell {
  aspect-ratio: 1;
  background-color: var(--cell-bg-color, #ecf0f1);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.2s;
}

.cell.has-item {
  background-color: transparent;
}

.item {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  cursor: grab;
  transition: transform 0.2s, box-shadow 0.2s, filter 0.2s;
  user-select: none;
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  position: relative;
}

.item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border-radius: 8px;
  background: rgba(0, 0, 0, 0.1);
  pointer-events: none;
}

.item:active {
  cursor: grabbing;
}

.item:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
}

.item.level-1 {
  border: 2px solid #667eea;
}

.item.level-2 {
  border: 2px solid #f093fb;
}

.item.level-3 {
  border: 2px solid #4facfe;
}

.item.level-4 {
  border: 2px solid #43e97b;
}

.item.level-5 {
  border: 2px solid #fa709a;
}

.item.level-6 {
  border: 2px solid #30cfd0;
}

.item.level-7 {
  border: 2px solid #a8edea;
}

.item.level-8 {
  border: 2px solid #ff9a56;
}

.item.level-9 {
  border: 2px solid #fbc2eb;
}

.item.level-10 {
  border: 2px solid #fddb92;
}

.item {
  --color-cycle: calc(var(--level-number, 1) * 36deg);
  border: 2px solid hsl(var(--color-cycle), 70%, 50%);
}

.controls {
  display: flex;
  gap: 15px;
  justify-content: center;
  flex-wrap: wrap;
}

.add-btn {
  background-color: #27ae60;
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 8px;
  font-size: 1.1em;
  cursor: pointer;
  transition: all 0.3s;
}

.add-btn:hover:not(.disabled) {
  background-color: #229954;
  transform: translateY(-2px);
}

.add-btn.disabled {
  background-color: #95a5a6;
  cursor: not-allowed;
  opacity: 0.7;
}

.shop-toggle-btn {
  background-color: #e67e22;
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 8px;
  font-size: 1.1em;
  cursor: pointer;
  transition: all 0.3s;
}

.shop-toggle-btn:hover {
  background-color: #d35400;
  transform: translateY(-2px);
}

.achievements-btn {
  background-color: #9b59b6;
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 8px;
  font-size: 1.1em;
  cursor: pointer;
  transition: all 0.3s;
}

.achievements-btn:hover {
  background-color: #8e44ad;
  transform: translateY(-2px);
}

.challenges-btn {
  background-color: #16a085;
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 8px;
  font-size: 1.1em;
  cursor: pointer;
  transition: all 0.3s;
}

.challenges-btn:hover {
  background-color: #138d75;
  transform: translateY(-2px);
}

.event-btn {
  background-color: #e74c3c;
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 8px;
  font-size: 1.1em;
  cursor: pointer;
  transition: all 0.3s;
}

.event-btn:hover {
  background-color: #c0392b;
  transform: translateY(-2px);
}

.rpg-world-btn {
  background-color: #8e44ad;
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 8px;
  font-size: 1.1em;
  cursor: pointer;
  transition: all 0.3s;
}

.rpg-world-btn:hover {
  background-color: #7d3c98;
  transform: translateY(-2px);
}

.rebirth-btn {
  background: linear-gradient(135deg, #16a085 0%, #1abc9c 100%);
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 8px;
  font-size: 1.1em;
  cursor: pointer;
  transition: all 0.3s;
}

.rebirth-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(26, 188, 156, 0.4);
}

.robot-btn {
  background-color: #95a5a6;
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 8px;
  font-size: 1.1em;
  cursor: pointer;
  transition: all 0.3s;
}

.robot-btn:hover {
  background-color: #7f8c8d;
  transform: translateY(-2px);
}

.robot-btn.active {
  background-color: #27ae60;
}

.robot-btn.active:hover {
  background-color: #229954;
}

.stat-item.player-level {
  background: linear-gradient(135deg, rgba(155, 89, 182, 0.1) 0%, rgba(142, 68, 173, 0.1) 100%);
  border-color: #9b59b6;
}

.stat-item.player-level .stat-value {
  color: #9b59b6;
}

.xp-bar-container {
  background: var(--stat-item-bg, rgba(52, 152, 219, 0.1));
  border-radius: 12px;
  padding: 15px 20px;
  margin-bottom: 20px;
  border: 2px solid var(--stat-item-border, #3498db);
}

.xp-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
  font-weight: 600;
  color: #2c3e50;
}

.xp-label {
  font-size: 1em;
}

.level-label {
  font-size: 1.1em;
  color: #9b59b6;
}

.xp-bar {
  background: var(--xp-bar-bg, #ecf0f1);
  border-radius: 10px;
  height: 20px;
  overflow: hidden;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
}

.xp-fill {
  background: var(--xp-fill-gradient, linear-gradient(90deg, #3498db 0%, #9b59b6 100%));
  height: 100%;
  transition: width 0.5s ease;
  border-radius: 10px;
  box-shadow: 0 2px 4px rgba(52, 152, 219, 0.3);
}

@media (prefers-color-scheme: light) {
  .game-header h1 {
    color: #2c3e50;
  }
}
</style>
