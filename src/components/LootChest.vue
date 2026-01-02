<template>
  <div class="chest-overlay" @click.self="close">
    <div class="chest-modal">
      <div class="modal-header">
        <h2>Coffre de Niveau {{ level }}</h2>
        <button @click="close" class="close-btn">✕</button>
      </div>

      <div class="chest-animation">
        <div class="chest-icon" :class="{ opening: isOpening }">
          {{ isOpening ? '📭' : '📦' }}
        </div>
        <button
          v-if="!isOpening && !opened"
          @click="openChest"
          class="open-btn"
        >
          Ouvrir le coffre
        </button>
      </div>

      <div v-if="opened" class="loot-display">
        <h3>Vous avez reçu:</h3>
        <div class="loot-grid">
          <div
            v-for="(loot, index) in loots"
            :key="index"
            class="loot-item"
            :class="`rarity-${loot.rarity}`"
          >
            <div class="loot-icon">{{ loot.icon }}</div>
            <div class="loot-name">{{ loot.name }}</div>
            <div class="loot-amount">{{ loot.amount }}</div>
          </div>
        </div>
        <button @click="close" class="claim-btn">Réclamer</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

interface Loot {
  icon: string
  name: string
  amount: number | string
  rarity: 'common' | 'rare' | 'epic' | 'legendary'
}

const props = defineProps<{
  level: number
}>()

const emit = defineEmits<{
  close: [loots: Loot[]]
}>()

const isOpening = ref(false)
const opened = ref(false)
const loots = ref<Loot[]>([])

const possibleLoots = [
  { icon: '💵', name: 'Or', type: 'gold', rarity: 'common' as const },
  { icon: '💎', name: 'Gemmes Premium', type: 'premium', rarity: 'rare' as const },
  { icon: '⭐', name: 'Points XP', type: 'xp', rarity: 'common' as const },
  { icon: '🎁', name: 'Élément Niveau 3', type: 'item3', rarity: 'rare' as const },
  { icon: '🎊', name: 'Élément Niveau 5', type: 'item5', rarity: 'epic' as const },
  { icon: '✨', name: 'Multiplicateur x2', type: 'multiplier', rarity: 'epic' as const },
  { icon: '🌟', name: 'Élément Niveau 8', type: 'item8', rarity: 'legendary' as const },
  { icon: '💫', name: 'Super Bonus', type: 'superbonus', rarity: 'legendary' as const }
]

const openChest = () => {
  isOpening.value = true

  setTimeout(() => {
    isOpening.value = false
    opened.value = true
    generateLoots()
  }, 1500)
}

const generateLoots = () => {
  const lootCount = Math.min(3 + Math.floor(props.level / 5), 5)
  const generatedLoots: Loot[] = []

  for (let i = 0; i < lootCount; i++) {
    const rarityRoll = Math.random()
    let availableLoots = possibleLoots

    if (rarityRoll < 0.5) {
      availableLoots = possibleLoots.filter(l => l.rarity === 'common')
    } else if (rarityRoll < 0.8) {
      availableLoots = possibleLoots.filter(l => l.rarity === 'rare')
    } else if (rarityRoll < 0.95) {
      availableLoots = possibleLoots.filter(l => l.rarity === 'epic')
    } else {
      availableLoots = possibleLoots.filter(l => l.rarity === 'legendary')
    }

    if (availableLoots.length === 0) {
      availableLoots = possibleLoots.filter(l => l.rarity === 'common')
    }

    const selectedLoot = availableLoots[Math.floor(Math.random() * availableLoots.length)]
    let amount: number | string = 0

    switch (selectedLoot.type) {
      case 'gold':
        amount = Math.floor(50 * props.level * (1 + Math.random()))
        break
      case 'premium':
        amount = Math.floor(1 + props.level / 3)
        break
      case 'xp':
        amount = Math.floor(20 * props.level * (1 + Math.random()))
        break
      case 'item3':
      case 'item5':
      case 'item8':
        amount = 'x1'
        break
      case 'multiplier':
        amount = 'x2 (1h)'
        break
      case 'superbonus':
        amount = Math.floor(500 * props.level)
        break
    }

    generatedLoots.push({
      icon: selectedLoot.icon,
      name: selectedLoot.name,
      amount: amount,
      rarity: selectedLoot.rarity
    })
  }

  loots.value = generatedLoots
}

const close = () => {
  emit('close', loots.value)
}
</script>

<style scoped>
.chest-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.85);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 20px;
}

.chest-modal {
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  border-radius: 16px;
  max-width: 600px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
  color: white;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 30px;
  border-bottom: 2px solid #1abc9c;
}

.modal-header h2 {
  margin: 0;
  font-size: 2em;
  color: #1abc9c;
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

.chest-animation {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 30px;
}

.chest-icon {
  font-size: 8em;
  margin-bottom: 30px;
  transition: all 0.5s;
}

.chest-icon.opening {
  animation: shake 0.5s ease-in-out;
}

@keyframes shake {
  0%, 100% { transform: rotate(0deg); }
  25% { transform: rotate(-10deg); }
  75% { transform: rotate(10deg); }
}

.open-btn {
  background: linear-gradient(135deg, #1abc9c 0%, #16a085 100%);
  color: white;
  border: none;
  padding: 15px 40px;
  border-radius: 8px;
  font-size: 1.3em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 15px rgba(26, 188, 156, 0.4);
}

.open-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(26, 188, 156, 0.6);
}

.loot-display {
  padding: 30px;
}

.loot-display h3 {
  text-align: center;
  font-size: 1.5em;
  margin: 0 0 30px 0;
  color: #1abc9c;
}

.loot-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 15px;
  margin-bottom: 30px;
}

.loot-item {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  border: 2px solid;
  transition: all 0.3s;
  animation: fadeIn 0.5s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.loot-item.rarity-common {
  border-color: #95a5a6;
  box-shadow: 0 4px 15px rgba(149, 165, 166, 0.3);
}

.loot-item.rarity-rare {
  border-color: #3498db;
  box-shadow: 0 4px 15px rgba(52, 152, 219, 0.5);
}

.loot-item.rarity-epic {
  border-color: #9b59b6;
  box-shadow: 0 4px 15px rgba(155, 89, 182, 0.5);
}

.loot-item.rarity-legendary {
  border-color: #f39c12;
  box-shadow: 0 4px 15px rgba(243, 156, 18, 0.5);
  animation: glow 2s ease-in-out infinite;
}

@keyframes glow {
  0%, 100% {
    box-shadow: 0 4px 15px rgba(243, 156, 18, 0.5);
  }
  50% {
    box-shadow: 0 4px 25px rgba(243, 156, 18, 0.8);
  }
}

.loot-item:hover {
  transform: translateY(-5px);
}

.loot-icon {
  font-size: 3em;
}

.loot-name {
  font-size: 1em;
  font-weight: 600;
  text-align: center;
}

.loot-amount {
  font-size: 1.2em;
  font-weight: bold;
  color: #1abc9c;
}

.claim-btn {
  width: 100%;
  background: linear-gradient(135deg, #1abc9c 0%, #16a085 100%);
  color: white;
  border: none;
  padding: 15px;
  border-radius: 8px;
  font-size: 1.2em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.claim-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(26, 188, 156, 0.4);
}
</style>
