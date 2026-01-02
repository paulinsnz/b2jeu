<template>
  <div class="shop-overlay" @click.self="closeShop">
    <div class="shop-container">
    <div class="shop-header">
      <h2>Shop</h2>
      <div class="gold-display">
        <span class="gold-icon">💵</span>
        <span class="gold-amount">{{ Math.floor(gold) }}</span>
      </div>
    </div>

    <div class="shop-section">
      <h3 class="section-title">Acheter des Parcelles</h3>
      <div class="parcel-upgrade">
        <div class="upgrade-info">
          <h4>+4 Parcelles</h4>
          <p>Augmente la taille du plateau de jeu</p>
          <div class="current-size">Taille actuelle: {{ currentBoardSize }} parcelles</div>
        </div>
        <div class="upgrade-cost">
          <div class="cost-value">{{ parcelCost }}</div>
          <button
            @click="buyParcels"
            :disabled="gold < parcelCost"
            class="buy-btn"
          >
            Acheter
          </button>
        </div>
      </div>
    </div>

    <div class="shop-section">
      <h3 class="section-title">Améliorer la Chance</h3>
      <div class="chance-upgrade">
        <div class="upgrade-info">
          <h4>Niveau de Chance: {{ chanceLevel }}</h4>
          <p>Augmente la probabilité d'obtenir des éléments de niveau supérieur</p>
          <div class="chance-description">
            <div>Niveau 1: 60% niveau 1</div>
            <div>Niveau 2+: Plus de chances pour niveaux supérieurs</div>
          </div>
        </div>
        <div class="upgrade-cost">
          <div class="cost-value">{{ chanceCost }}</div>
          <button
            @click="upgradeChance"
            :disabled="gold < chanceCost"
            class="buy-btn"
          >
            Améliorer
          </button>
        </div>
      </div>
    </div>

    <div class="shop-section">
      <h3 class="section-title">Améliorer le Niveau Max du Joueur</h3>
      <div class="max-level-upgrade">
        <div class="upgrade-info">
          <h4>Niveau Max Joueur: {{ maxLevel }}</h4>
          <p>Augmente le niveau maximum du joueur</p>
          <div class="max-level-description">
            Limite actuelle: Niveau {{ maxLevel }} maximum pour le joueur
          </div>
        </div>
        <div class="upgrade-cost">
          <div class="cost-value">{{ maxLevelCost }}</div>
          <button
            @click="upgradeMaxLevel"
            :disabled="gold < maxLevelCost"
            class="buy-btn"
          >
            Améliorer
          </button>
        </div>
      </div>
    </div>

    <div class="shop-section">
      <h3 class="section-title">Améliorer les Niveaux</h3>
      <div class="upgrades-grid">
        <div
          v-for="level in levelUpgrades"
          :key="level.level"
          class="level-upgrade-item"
          :class="{ disabled: gold < level.cost }"
        >
          <div class="level-header">
            <div class="level-number" :class="`level-${level.level}`">{{ level.level }}</div>
            <div class="level-info">
              <div class="level-name">Niveau {{ level.level }}</div>
              <div class="level-multiplier">Multiplicateur: x{{ level.multiplier.toFixed(1) }}</div>
            </div>
          </div>
          <div class="level-income">
            <span class="income-label">Revenu/sec:</span>
            <span class="income-value">💵 {{ (level.level * 0.1 * level.multiplier).toFixed(2) }}</span>
          </div>
          <div class="upgrade-cost">
            <div class="cost-value">{{ level.cost }}</div>
            <button
              @click="upgradeLevelIncome(level)"
              :disabled="gold < level.cost"
              class="buy-btn"
            >
              Améliorer
            </button>
          </div>
        </div>
      </div>
    </div>

    

    <div class="shop-section">
      <h3 class="section-title">Premium</h3>
      <div class="premium-info">
        <div class="premium-currency">
          <span class="premium-icon">💎</span>
          <span class="premium-amount">{{ premiumCurrency }}</span>
        </div>
        <button @click="showCodeInput = !showCodeInput" class="code-btn">
          {{ showCodeInput ? 'Annuler' : 'Entrer un code' }}
        </button>
      </div>

      <div v-if="showCodeInput" class="code-input-section">
        <input
          v-model="codeInput"
          type="text"
          placeholder="Entrez votre code premium"
          class="code-input"
          @keyup.enter="redeemCode"
        />
        <button @click="redeemCode" class="redeem-btn">Valider</button>
      </div>

      <div class="premium-boosts-grid">
        <div
          v-for="boost in premiumBoosts"
          :key="boost.id"
          class="premium-boost-item"
          :class="{ disabled: premiumCurrency < boost.cost, active: activeBoosts[boost.id] }"
        >
          <div class="boost-header">
            <div class="boost-icon">{{ boost.icon }}</div>
            <div class="boost-info">
              <div class="boost-name">{{ boost.name }}</div>
              <div class="boost-description">{{ boost.description }}</div>
            </div>
          </div>
          <div class="boost-effect">
            <span class="effect-label">Effet:</span>
            <span class="effect-value">{{ boost.effect }}</span>
          </div>
          <div class="upgrade-cost">
            <div class="cost-value premium-cost">
              <span class="premium-icon-small">💎</span>
              {{ boost.cost }}
            </div>
            <button
              @click="buyPremiumBoost(boost)"
              :disabled="premiumCurrency < boost.cost || activeBoosts[boost.id]"
              class="buy-btn"
            >
              {{ activeBoosts[boost.id] ? 'Actif' : 'Acheter' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <button @click="closeShop" class="close-shop-btn">Fermer</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, watch } from 'vue'

interface LevelUpgrade {
  level: number
  multiplier: number
  cost: number
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

const props = defineProps<{
  gold: number
  currentBoardSize: number
  levelMultipliers: Record<number, number>
  premiumCurrency: number
  activeBoosts: Record<string, boolean>
  autoBuyEnabled: boolean
  chanceLevel: number
  maxLevel: number
  parcelCost: number
  levelCosts: Record<number, number>
  chanceCost: number
  maxLevelCost: number
}>()

const emit = defineEmits<{
  upgradeLevelIncome: [level: number]
  buyParcels: []
  redeemCode: [code: string]
  buyPremiumBoost: [boost: PremiumBoost]
  toggleAutoBuy: []
  upgradeChance: []
  upgradeMaxLevel: []
  close: []
}>()

const levelUpgrades = reactive<LevelUpgrade[]>([
  { level: 1, multiplier: props.levelMultipliers[1] || 1, cost: props.levelCosts[1] },
  { level: 2, multiplier: props.levelMultipliers[2] || 1, cost: props.levelCosts[2] },
  { level: 3, multiplier: props.levelMultipliers[3] || 1, cost: props.levelCosts[3] },
  { level: 4, multiplier: props.levelMultipliers[4] || 1, cost: props.levelCosts[4] },
  { level: 5, multiplier: props.levelMultipliers[5] || 1, cost: props.levelCosts[5] },
  { level: 6, multiplier: props.levelMultipliers[6] || 1, cost: props.levelCosts[6] },
  { level: 7, multiplier: props.levelMultipliers[7] || 1, cost: props.levelCosts[7] },
  { level: 8, multiplier: props.levelMultipliers[8] || 1, cost: props.levelCosts[8] },
  { level: 9, multiplier: props.levelMultipliers[9] || 1, cost: props.levelCosts[9] },
  { level: 10, multiplier: props.levelMultipliers[10] || 1, cost: props.levelCosts[10] }
])

watch(() => props.levelMultipliers, (newMultipliers) => {
  levelUpgrades.forEach(upgrade => {
    upgrade.multiplier = newMultipliers[upgrade.level] || 1
  })
}, { deep: true })

watch(() => props.levelCosts, (newCosts) => {
  levelUpgrades.forEach(upgrade => {
    upgrade.cost = newCosts[upgrade.level]
  })
}, { deep: true })

const upgradeLevelIncome = (level: LevelUpgrade) => {
  if (props.gold >= level.cost) {
    emit('upgradeLevelIncome', level.level)
  }
}

const buyParcels = () => {
  if (props.gold >= props.parcelCost) {
    emit('buyParcels')
  }
}

const upgradeChance = () => {
  if (props.gold >= props.chanceCost) {
    emit('upgradeChance')
  }
}

const upgradeMaxLevel = () => {
  if (props.gold >= props.maxLevelCost) {
    emit('upgradeMaxLevel')
  }
}

const showCodeInput = ref(false)
const codeInput = ref('')

const premiumBoosts = reactive<PremiumBoost[]>([
  {
    id: 'double-gold',
    name: 'Double Or',
    description: 'Double tous les gains d\'or',
    icon: '⚡',
    effect: 'x2 Or',
    cost: 10
  },
  {
    id: 'triple-merge',
    name: 'Triple Fusion',
    description: 'Triple les gains lors des fusions',
    icon: '🔮',
    effect: 'x3 Fusion',
    cost: 15
  },
  {
    id: 'auto-merge',
    name: 'Fusion Auto',
    description: 'Fusionne automatiquement les éléments identiques',
    icon: '🤖',
    effect: 'Automatique',
    cost: 0
  },
  {
    id: 'auto-buy',
    name: 'Achat Auto',
    description: 'Achète automatiquement les éléments quand vous avez assez d\'argent',
    icon: '🛒',
    effect: 'Automatique',
    cost: 0
  },
  {
    id: 'mega-boost',
    name: 'Méga Boost',
    description: 'Multiplie tous les revenus par 5',
    icon: '💫',
    effect: 'x5 Tout',
    cost: 50
  }
])

const redeemCode = () => {
  if (codeInput.value.trim()) {
    emit('redeemCode', codeInput.value.trim())
    codeInput.value = ''
    showCodeInput.value = false
  }
}

const buyPremiumBoost = (boost: PremiumBoost) => {
  if (props.premiumCurrency >= boost.cost && !props.activeBoosts[boost.id]) {
    emit('buyPremiumBoost', boost)
  }
}

const closeShop = () => {
  emit('close')
}
</script>

<style scoped>
.shop-overlay {
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

.shop-container {
  background: linear-gradient(135deg, #ffffff 0%, #f5f7fa 100%);
  border-radius: 16px;
  padding: 30px;
  max-width: 1200px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

.shop-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  border-bottom: 2px solid #34495e;
  padding-bottom: 15px;
}

.shop-header h2 {
  margin: 0;
  font-size: 1.8em;
  color: #2c3e50;
}

.gold-display {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.5em;
  font-weight: bold;
  background: rgba(255, 215, 0, 0.1);
  padding: 10px 15px;
  border-radius: 8px;
  border: 2px solid #f39c12;
}

.gold-icon {
  font-size: 1.5em;
}

.gold-amount {
  color: #f39c12;
  min-width: 80px;
}

.shop-section {
  margin-bottom: 30px;
}

.section-title {
  font-size: 1.3em;
  color: #2c3e50;
  margin: 0 0 15px 0;
  padding-bottom: 10px;
  border-bottom: 1px solid #bdc3c7;
}

.parcel-upgrade,
.chance-upgrade {
  background: white;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border: 2px solid #3498db;
}

.chance-upgrade {
  border-color: #27ae60;
}

.max-level-upgrade {
  background: white;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border: 2px solid #e74c3c;
}

.parcel-upgrade .upgrade-info h4 {
  margin: 0 0 8px 0;
  font-size: 1.2em;
  color: #2c3e50;
}

.parcel-upgrade .upgrade-info p {
  margin: 0 0 8px 0;
  font-size: 0.9em;
  color: #7f8c8d;
}

.current-size {
  font-size: 0.9em;
  color: #3498db;
  font-weight: 600;
}

.parcel-upgrade .upgrade-info,
.chance-upgrade .upgrade-info,
.max-level-upgrade .upgrade-info {
  flex: 1;
}

.chance-description {
  font-size: 0.85em;
  color: #27ae60;
  font-weight: 600;
  margin-top: 8px;
}

.max-level-description {
  font-size: 0.85em;
  color: #e74c3c;
  font-weight: 600;
  margin-top: 8px;
}

.upgrades-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 15px;
}

.level-upgrade-item {
  background: white;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
  border: 2px solid transparent;
}

.level-upgrade-item:hover:not(.disabled) {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  border-color: #3498db;
}

.level-upgrade-item.disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.level-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.level-number {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5em;
  font-weight: bold;
  color: white;
  flex-shrink: 0;
}

.level-number.level-1 {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.level-number.level-2 {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.level-number.level-3 {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.level-number.level-4 {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.level-number.level-5 {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.level-number.level-6 {
  background: linear-gradient(135deg, #30cfd0 0%, #330867 100%);
}

.level-number.level-7 {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  color: #2c3e50;
}

.level-number.level-8 {
  background: linear-gradient(135deg, #ff9a56 0%, #ff6a88 100%);
}

.level-number.level-9 {
  background: linear-gradient(135deg, #fbc2eb 0%, #a6c1ee 100%);
  color: #2c3e50;
}

.level-number.level-10 {
  background: linear-gradient(135deg, #fddb92 0%, #d1fdff 100%);
  color: #2c3e50;
}

.level-info {
  flex-grow: 1;
}

.level-name {
  font-size: 1em;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 4px;
}

.level-multiplier {
  font-size: 0.85em;
  color: #27ae60;
  font-weight: 600;
}

.level-income {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(52, 152, 219, 0.1);
  padding: 8px 12px;
  border-radius: 6px;
  margin-bottom: 12px;
}

.income-label {
  font-size: 0.85em;
  color: #7f8c8d;
  font-weight: 500;
}

.income-value {
  font-size: 1em;
  font-weight: bold;
  color: #f39c12;
}

.upgrade-cost {
  display: flex;
  align-items: center;
  gap: 10px;
}

.cost-value {
  background: #f39c12;
  color: white;
  padding: 8px 12px;
  border-radius: 6px;
  font-weight: bold;
  font-size: 1em;
  min-width: 50px;
  text-align: center;
}

.buy-btn {
  flex-grow: 1;
  background: #27ae60;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.3s;
}

.buy-btn:hover:not(:disabled) {
  background: #229954;
}

.buy-btn:disabled {
  background: #95a5a6;
  cursor: not-allowed;
}

.premium-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 15px 20px;
  border-radius: 8px;
}

.premium-currency {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.5em;
  font-weight: bold;
  color: white;
}

.premium-icon {
  font-size: 1.5em;
}

.premium-amount {
  min-width: 60px;
}

.code-btn {
  background: white;
  color: #667eea;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.code-btn:hover {
  background: #f0f0f0;
  transform: scale(1.05);
}

.code-input-section {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.code-input {
  flex-grow: 1;
  padding: 12px 16px;
  border: 2px solid #667eea;
  border-radius: 6px;
  font-size: 1em;
  outline: none;
  transition: border-color 0.3s;
}

.code-input:focus {
  border-color: #764ba2;
}

.redeem-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.redeem-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.premium-boosts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 15px;
}

.premium-boost-item {
  background: white;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
  border: 2px solid transparent;
}

.premium-boost-item:hover:not(.disabled):not(.active) {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
  border-color: #667eea;
}

.premium-boost-item.disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.premium-boost-item.active {
  border-color: #27ae60;
  background: linear-gradient(135deg, rgba(39, 174, 96, 0.1) 0%, rgba(46, 204, 113, 0.1) 100%);
}

.boost-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.boost-icon {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2em;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  flex-shrink: 0;
}

.boost-info {
  flex-grow: 1;
}

.boost-name {
  font-size: 1.1em;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 4px;
}

.boost-description {
  font-size: 0.85em;
  color: #7f8c8d;
  line-height: 1.3;
}

.boost-effect {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(102, 126, 234, 0.1);
  padding: 8px 12px;
  border-radius: 6px;
  margin-bottom: 12px;
}

.effect-label {
  font-size: 0.85em;
  color: #7f8c8d;
  font-weight: 500;
}

.effect-value {
  font-size: 1em;
  font-weight: bold;
  color: #667eea;
}

.premium-cost {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  gap: 5px;
}

.premium-icon-small {
  font-size: 1em;
}

.close-shop-btn {
  width: 100%;
  background: #e74c3c;
  color: white;
  border: none;
  padding: 12px;
  border-radius: 8px;
  font-size: 1.1em;
  font-weight: 600;
  cursor: pointer;
  margin-top: 20px;
  transition: all 0.3s;
}

.close-shop-btn:hover {
  background: #c0392b;
  transform: translateY(-2px);
}

.robot-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border: 2px solid #3498db;
}

.robot-info {
  display: flex;
  align-items: center;
  gap: 15px;
  flex: 1;
}

.robot-icon {
  font-size: 2em;
  min-width: 50px;
  text-align: center;
}

.robot-details {
  flex: 1;
}

.robot-name {
  font-size: 1.1em;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 4px;
}

.robot-description {
  font-size: 0.9em;
  color: #7f8c8d;
  line-height: 1.3;
}

.auto-buy-btn {
  background: #95a5a6;
  color: white;
  border: none;
  padding: 10px 24px;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  white-space: nowrap;
}

.auto-buy-btn:hover {
  background: #7f8c8d;
}

.auto-buy-btn.active {
  background: #27ae60;
}

.auto-buy-btn.active:hover {
  background: #229954;
}
</style>
