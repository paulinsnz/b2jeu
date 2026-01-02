<template>
  <div class="rpg-world-overlay" @click.self="closeRPGWorld">
    <div class="rpg-world-container">
      <div class="rpg-world-header">
        <div class="header-info">
          <h2>Monde RPG</h2>
          <div class="stats-bar">
            <div class="stat-item">
              <span class="stat-label">Or:</span>
              <span class="stat-value gold-text">{{ playerGold }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Monstres vaincus:</span>
              <span class="stat-value">{{ combatStats.monstersDefeated }}</span>
            </div>
          </div>
        </div>
        <div class="header-actions">
          <button @click="showStory = true" class="story-btn">📖 Histoire</button>
          <button @click="showAutoSellPanel = !showAutoSellPanel" class="auto-sell-btn">⚙ Auto-Vente</button>
          <button @click="closeRPGWorld" class="close-btn">✕</button>
        </div>
      </div>
      <div v-if="showAutoSellPanel" class="auto-sell-panel">
        <div class="panel-header">
          <h3>Paramètres d'Auto-Vente</h3>
          <button @click="showAutoSellPanel = false" class="panel-close">✕</button>
        </div>
        <div class="rarity-toggles">
          <div v-for="setting in autoSellSettings" :key="setting.rarity" class="toggle-item">
            <label class="toggle-label">
              <input
                type="checkbox"
                :checked="setting.enabled"
                @change="(e) => toggleAutoSellSetting(setting.rarity, (e.target as HTMLInputElement).checked)"
                class="toggle-checkbox"
              />
              <span class="rarity-name" :class="`rarity-${setting.rarity}`">{{ setting.rarity }}</span>
            </label>
          </div>
        </div>
        <button @click="performAutoSell" class="perform-auto-sell-btn">Vendre maintenant</button>
        <div v-if="lastAutoSellGold > 0" class="auto-sell-result">
          +{{ lastAutoSellGold }} or gagné!
        </div>
      </div>

      <div v-if="showStory" class="story-modal-overlay" @click.self="showStory = false">
        <div class="story-modal">
          <div class="story-header">
            <h2>📖 L'Histoire du Monde RPG</h2>
            <button @click="showStory = false" class="story-close">✕</button>
          </div>
          <div class="story-content">
            <button @click="showStoryMode = true; showStory = false" class="story-mode-btn">Commencer la Campagne</button>
          </div>
        </div>
      </div>

      <StoryMode v-if="showStoryMode" :userId="props.userId" @close="showStoryMode = false" />

      <div class="rpg-world-content">
        <div class="combat-area">
          <div v-if="inCombat" class="combat-section">
            <div class="combat-header">
              <div class="combatant player-side">
                <h4>Vous</h4>
              </div>

              <div class="vs-text">VS</div>

              <div class="combatant monster-side">
                <div v-if="currentMonster" class="monster-image-container">
                  <img :src="currentMonster.imageUrl" :alt="currentMonster.name" class="monster-image" />
                </div>
                <h4>{{ currentMonster?.name }}</h4>
                <div class="health-bar monster">
                  <div class="health-fill monster-fill" :style="{ width: monsterHealthPercent + '%' }"></div>
                </div>
                <p class="health-text">{{ currentMonster?.health }} / {{ currentMonster?.maxHealth }} HP</p>
              </div>
            </div>

            <div v-if="combatEnded && combatWon" class="victory-message">
              <h4>Victoire!</h4>
              <p>+{{ lastRewardGold }} or gagné!</p>
              <p>+{{ lastRewardXp }} XP gagné!</p>
              <div v-if="lastDrops.length > 0" class="drops-section">
                <h5>Butin obtenu:</h5>
                <div class="drops-list">
                  <div v-for="drop in lastDrops" :key="drop.id" :class="['drop-item', `rarity-${drop.rarity}`]">
                    <p class="drop-name">{{ drop.name }}</p>
                    <p class="rarity-badge">{{ drop.rarity }}</p>
                  </div>
                </div>
              </div>
              <p v-else class="no-drops">Aucun équipement obtenu...</p>
            </div>

          </div>
        </div>

        <div class="inventory-section">
          <h3>Inventaire</h3>
          <div class="inventory-container">
            <div class="equipped-items">
              <div class="slot-title">Équipés</div>
              <div class="equipment-slots">
                <div v-for="(slot, slotName) in getEquippedItems()" :key="slotName" class="slot-item equipped">
                  <div class="slot-name">{{ formatSlotName(slotName) }}</div>
                  <div v-if="slot" class="equipped-item" :class="`rarity-${slot.rarity}`">
                    <p class="item-name">{{ slot.name }}</p>
                    <p v-if="slot.damage_bonus > 0" class="stat">+{{ slot.damage_bonus }} ATK</p>
                    <p v-if="slot.defense_bonus > 0" class="stat">+{{ slot.defense_bonus }} DEF</p>
                    <p v-if="slot.health_bonus > 0" class="stat">+{{ slot.health_bonus }} HP</p>
                    <button @click="unequipItem(slotName)" class="unequip-btn">Retirer</button>
                  </div>
                  <div v-else class="empty-slot">Vide</div>
                </div>
              </div>
            </div>

            <div class="unequipped-items">
              <div class="slot-title">Disponibles</div>
              <div v-if="(playerEquipment?.inventory || []).length > 0">
                <template v-for="cat in getInventoryCategories()" :key="cat.name">
                  <div v-if="cat.items.length > 0" class="inventory-category">
                    <div class="category-header">{{ cat.name }}</div>
                    <div class="items-grid">
                      <div
                        v-for="(item, index) in cat.items"
                        :key="index"
                        :class="['inventory-item', `rarity-${item.rarity}`]"
                      >
                        <p class="item-name">{{ item.name }}</p>
                        <p class="item-type">{{ item.equipment_slot }}</p>
                        <p v-if="item.damage_bonus > 0" class="stat">+{{ item.damage_bonus }} ATK</p>
                        <p v-if="item.defense_bonus > 0" class="stat">+{{ item.defense_bonus }} DEF</p>
                        <p v-if="item.health_bonus > 0" class="stat">+{{ item.health_bonus }} HP</p>
                        <div class="item-actions">
                          <button @click="equipItemFromInventory(item)" class="equip-btn">Équiper</button>
                          <button @click="deleteItem(item.id)" class="delete-btn">Supprimer</button>
                        </div>
                      </div>
                    </div>
                  </div>
                </template>
              </div>
              <div v-else class="empty-inventory">
                Aucun équipement dans l'inventaire
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import {
  generateRandomMonster,
  calculateDamage,
  saveCombatLog,
  addGold,
  getPlayerGold,
  getCombatStats,
  generateDrops,
  addDroppedEquipment,
  type Monster,
} from '../services/combatService'
import { getPlayerEquipment, equipItem, deleteItemFromInventory, getAutoSellSettings, updateAutoSellSetting, autoSellEquipment, type Equipment, type PlayerEquipment, type AutoSellSettings } from '../services/equipmentService'
import StoryMode from './StoryMode.vue'

const props = defineProps<{
  userId: string
}>()

const emit = defineEmits<{
  close: []
}>()

const currentMonster = ref<Monster | null>(null)
const inCombat = ref(false)
const combatEnded = ref(false)
const combatWon = ref(false)
const lastRewardGold = ref(0)
const lastRewardXp = ref(0)
const playerGold = ref(0)
const combatStats = ref({ totalGold: 0, monstersDefeated: 0 })
const playerEquipment = ref<PlayerEquipment | null>(null)
const lastDrops = ref<Equipment[]>([])
const autoCombatInterval = ref<number | null>(null)
const playerAttackSpeed = ref(1000)
const autoSellSettings = ref<AutoSellSettings[]>([])
const showAutoSellPanel = ref(false)
const lastAutoSellGold = ref(0)
const showStory = ref(false)
const showStoryMode = ref(false)

const monsterHealthPercent = computed(() =>
  currentMonster.value ? (currentMonster.value.health / currentMonster.value.maxHealth) * 100 : 0
)

onMounted(async () => {
  if (props.userId) {
    playerGold.value = await getPlayerGold(props.userId)
    combatStats.value = await getCombatStats(props.userId)
    playerEquipment.value = await getPlayerEquipment(props.userId)
    autoSellSettings.value = await getAutoSellSettings(props.userId)
    updateAttackSpeed()
    startCombat()
  }
})

onUnmounted(() => {
  if (autoCombatInterval.value) {
    clearInterval(autoCombatInterval.value)
  }
})

const getEquippedWeapon = () => {
  if (!playerEquipment.value?.weapon_id || !playerEquipment.value?.inventory) {
    return null
  }
  return playerEquipment.value.inventory.find(
    (item) => item.id === playerEquipment.value?.weapon_id && item.equipment_slot === 'weapon'
  )
}


const updateAttackSpeed = () => {
  const weapon = getEquippedWeapon()
  if (weapon) {
    const weaponDamage = weapon.damage_bonus || 0
    playerAttackSpeed.value = Math.max(500, 1000 - weaponDamage * 20)
  } else {
    playerAttackSpeed.value = 1000
  }
}

const startCombat = () => {
  currentMonster.value = generateRandomMonster()
  inCombat.value = true
  combatEnded.value = false
  combatWon.value = false
  startAutoCombat()
}

const playerAttack = async () => {
  if (!currentMonster.value) return

  const weapon = getEquippedWeapon()
  const weaponBonus = weapon?.damage_bonus || 0
  const damage = calculateDamage(1) + weaponBonus
  currentMonster.value.health -= damage

  if (currentMonster.value.health <= 0) {
    await endCombat(true)
    return
  }
}

const endCombat = async (won: boolean) => {
  if (!currentMonster.value) return

  combatEnded.value = true
  combatWon.value = won

  if (won) {
    const goldReward = currentMonster.value.baseGoldReward
    const xpReward = currentMonster.value.baseXpReward

    lastRewardGold.value = goldReward
    lastRewardXp.value = xpReward

    if (props.userId) {
      await addGold(props.userId, goldReward)
      await saveCombatLog(props.userId, currentMonster.value.name, goldReward, xpReward)

      const drops = await generateDrops(currentMonster.value.name, currentMonster.value.difficulty)
      lastDrops.value = drops

      for (const drop of drops) {
        await addDroppedEquipment(props.userId, drop)
      }

      playerGold.value = await getPlayerGold(props.userId)
      combatStats.value = await getCombatStats(props.userId)
      playerEquipment.value = await getPlayerEquipment(props.userId)
    }
  }

  setTimeout(() => resetCombat(), 3000)
}

const resetCombat = () => {
  combatEnded.value = false
  currentMonster.value = null
  setTimeout(() => startCombat(), 500)
}

const getEquippedItems = () => {
  if (!playerEquipment.value) return {}

  const equipped: Record<string, Equipment | null> = {
    weapon: null,
    helmet: null,
    chest: null,
    legs: null,
    feet: null,
    accessory1: null,
    accessory2: null,
  }

  if (playerEquipment.value.weapon_id && playerEquipment.value.inventory) {
    equipped.weapon = playerEquipment.value.inventory.find((item) => item.id === playerEquipment.value?.weapon_id) || null
  }

  if (playerEquipment.value.helmet_id && playerEquipment.value.inventory) {
    equipped.helmet = playerEquipment.value.inventory.find((item) => item.id === playerEquipment.value?.helmet_id) || null
  }

  if (playerEquipment.value.chest_id && playerEquipment.value.inventory) {
    equipped.chest = playerEquipment.value.inventory.find((item) => item.id === playerEquipment.value?.chest_id) || null
  }

  if (playerEquipment.value.legs_id && playerEquipment.value.inventory) {
    equipped.legs = playerEquipment.value.inventory.find((item) => item.id === playerEquipment.value?.legs_id) || null
  }

  if (playerEquipment.value.feet_id && playerEquipment.value.inventory) {
    equipped.feet = playerEquipment.value.inventory.find((item) => item.id === playerEquipment.value?.feet_id) || null
  }

  if (playerEquipment.value.accessory1_id && playerEquipment.value.inventory) {
    equipped.accessory1 = playerEquipment.value.inventory.find((item) => item.id === playerEquipment.value?.accessory1_id) || null
  }

  if (playerEquipment.value.accessory2_id && playerEquipment.value.inventory) {
    equipped.accessory2 = playerEquipment.value.inventory.find((item) => item.id === playerEquipment.value?.accessory2_id) || null
  }

  return equipped
}

const formatSlotName = (slotName: string): string => {
  const names: Record<string, string> = {
    weapon: 'Arme',
    helmet: 'Casque',
    chest: 'Plastron',
    legs: 'Jambières',
    feet: 'Bottes',
    accessory1: 'Accessoire 1',
    accessory2: 'Accessoire 2',
  }
  return names[slotName] || slotName
}

const getSlotForItemType = (equipmentType: string): 'weapon' | 'helmet' | 'chest' | 'legs' | 'feet' | 'accessory1' | 'accessory2' | null => {
  const slotMap: Record<string, 'weapon' | 'helmet' | 'chest' | 'legs' | 'feet' | 'accessory1' | 'accessory2'> = {
    weapon: 'weapon',
    helmet: 'helmet',
    chest: 'chest',
    legs: 'legs',
    feet: 'feet',
    accessory: 'accessory1',
  }
  return slotMap[equipmentType] || null
}

interface InventoryCategory {
  name: string
  items: Equipment[]
}

const getInventoryCategories = (): InventoryCategory[] => {
  const inventory = playerEquipment.value?.inventory || []

  const categoryMap: Record<string, Equipment[]> = {
    'Armes': [],
    'Casques': [],
    'Plastrons': [],
    'Jambières': [],
    'Bottes': [],
    'Accessoires': [],
  }

  inventory.forEach(item => {
    const slot = item.equipment_slot || ''
    if (slot === 'weapon') {
      categoryMap['Armes'].push(item)
    } else if (slot === 'helmet') {
      categoryMap['Casques'].push(item)
    } else if (slot === 'chest') {
      categoryMap['Plastrons'].push(item)
    } else if (slot === 'legs') {
      categoryMap['Jambières'].push(item)
    } else if (slot === 'feet') {
      categoryMap['Bottes'].push(item)
    } else if (slot === 'accessory') {
      categoryMap['Accessoires'].push(item)
    }
  })

  return Object.entries(categoryMap).map(([name, items]) => ({ name, items }))
}

const equipItemFromInventory = async (item: Equipment) => {
  if (!playerEquipment.value || !props.userId) return

  const slot = getSlotForItemType(item.equipment_slot)
  if (!slot) return

  const success = await equipItem(props.userId, item.id, slot)

  if (success) {
    playerEquipment.value = await getPlayerEquipment(props.userId)
    updateAttackSpeed()
  }
}

const unequipItem = async (slotName: string) => {
  if (!playerEquipment.value || !props.userId) return

  const slot = slotName as 'weapon' | 'helmet' | 'chest' | 'legs' | 'feet' | 'accessory1' | 'accessory2'
  const success = await equipItem(props.userId, null, slot)

  if (success) {
    playerEquipment.value = await getPlayerEquipment(props.userId)
    updateAttackSpeed()
  }
}

const deleteItem = async (itemId: string) => {
  if (!props.userId) return

  const success = await deleteItemFromInventory(props.userId, itemId)

  if (success) {
    playerEquipment.value = await getPlayerEquipment(props.userId)
  }
}

const startAutoCombat = () => {
  if (autoCombatInterval.value) {
    clearInterval(autoCombatInterval.value)
  }
  autoCombatInterval.value = window.setInterval(async () => {
    if (inCombat.value && !combatEnded.value && currentMonster.value) {
      await playerAttack()
    }
  }, playerAttackSpeed.value)
}

const stopAutoCombat = () => {
  if (autoCombatInterval.value) {
    clearInterval(autoCombatInterval.value)
    autoCombatInterval.value = null
  }
}


const toggleAutoSellSetting = async (rarity: string, enabled: boolean) => {
  if (!props.userId) return

  const success = await updateAutoSellSetting(props.userId, rarity, enabled)
  if (success) {
    autoSellSettings.value = await getAutoSellSettings(props.userId)
  }
}

const performAutoSell = async () => {
  if (!props.userId) return

  const goldEarned = await autoSellEquipment(props.userId)
  lastAutoSellGold.value = goldEarned

  playerGold.value = await getPlayerGold(props.userId)
  playerEquipment.value = await getPlayerEquipment(props.userId)

  if (goldEarned > 0) {
    setTimeout(() => {
      lastAutoSellGold.value = 0
    }, 3000)
  }
}

const closeRPGWorld = () => {
  stopAutoCombat()
  emit('close')
}
</script>

<style scoped>
.rpg-world-overlay {
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

.rpg-world-container {
  background: linear-gradient(135deg, #ffffff 0%, #f5f7fa 100%);
  border-radius: 16px;
  padding: 30px;
  max-width: 1200px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

.rpg-world-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  border-bottom: 2px solid #34495e;
  padding-bottom: 15px;
  gap: 15px;
}

.header-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.story-btn {
  background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9em;
  transition: all 0.3s;
}

.story-btn:hover {
  background: linear-gradient(135deg, #2980b9 0%, #1f618d 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
}

.auto-sell-btn {
  background: linear-gradient(135deg, #16a085 0%, #138d75 100%);
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9em;
  transition: all 0.3s;
}

.auto-sell-btn:hover {
  background: linear-gradient(135deg, #138d75 0%, #0e6251 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(22, 160, 133, 0.3);
}

.header-info {
  display: flex;
  gap: 30px;
  align-items: center;
}

.header-info h2 {
  margin: 0;
  font-size: 1.8em;
  color: #2c3e50;
  margin-right: 10px;
}

.stats-bar {
  display: flex;
  gap: 20px;
}

.stat-item {
  display: flex;
  gap: 8px;
  align-items: center;
  font-size: 1.1em;
}

.stat-label {
  color: #7f8c8d;
  font-weight: 600;
}

.stat-value {
  font-weight: bold;
  font-size: 1.2em;
  color: #2c3e50;
}

.gold-text {
  color: #f39c12;
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

.rpg-world-content {
  min-height: 400px;
}

.combat-area {
  display: flex;
  flex-direction: column;
  gap: 20px;
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
  background: linear-gradient(135deg, #ecf0f1 0%, #d5dbdb 100%);
  border-radius: 12px;
}

.combatant {
  flex: 1;
  text-align: center;
}

.combatant h4 {
  margin: 0 0 10px 0;
  font-size: 1.3em;
  color: #2c3e50;
}

.health-bar {
  width: 100%;
  height: 25px;
  background: #bdc3c7;
  border-radius: 8px;
  overflow: hidden;
  margin: 10px 0;
  border: 2px solid #34495e;
}

.health-fill.monster-fill {
  height: 100%;
  background: linear-gradient(90deg, #e74c3c 0%, #c0392b 100%);
  transition: width 0.3s ease;
}

.health-text {
  margin: 5px 0 0 0;
  color: #7f8c8d;
  font-size: 0.9em;
}

.vs-text {
  font-size: 1.5em;
  font-weight: bold;
  color: #2c3e50;
  margin: 0 20px;
}


.combat-actions {
  display: flex;
  gap: 10px;
  justify-content: center;
}


button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.victory-message,
.defeat-message {
  padding: 20px;
  border-radius: 8px;
  text-align: center;
}

.victory-message {
  background: linear-gradient(135deg, #d5f4e6 0%, #a9dfbf 100%);
  border: 2px solid #27ae60;
  color: #27ae60;
}

.victory-message h4 {
  margin: 0 0 10px 0;
  font-size: 1.5em;
}

.victory-message p {
  margin: 5px 0;
  font-weight: bold;
}

.drops-section {
  margin-top: 15px;
  padding-top: 15px;
  border-top: 2px solid rgba(39, 174, 96, 0.3);
}

.drops-section h5 {
  margin: 0 0 10px 0;
  color: #27ae60;
  font-size: 1em;
}

.drops-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 8px;
}

.drop-item {
  padding: 8px;
  border-radius: 6px;
  border: 2px solid #bdc3c7;
  background: white;
  text-align: center;
  animation: dropPulse 0.5s ease-out;
}

.drop-item.rarity-common {
  border-color: #95a5a6;
  background: #ecf0f1;
}

.drop-item.rarity-uncommon {
  border-color: #27ae60;
  background: #d5f4e6;
}

.drop-item.rarity-rare {
  border-color: #3498db;
  background: #d6eaf8;
}

.drop-item.rarity-epic {
  border-color: #9b59b6;
  background: #e8daef;
}

.drop-item.rarity-legendary {
  border-color: #f39c12;
  background: #fef5e7;
}

.drop-name {
  margin: 0;
  font-size: 0.9em;
  font-weight: 600;
  color: #2c3e50;
}

.rarity-badge {
  margin: 3px 0 0 0;
  font-size: 0.75em;
  color: #7f8c8d;
  text-transform: capitalize;
  font-weight: 500;
}

.no-drops {
  margin: 10px 0 0 0;
  font-size: 0.9em;
  color: #7f8c8d;
  font-style: italic;
}

@keyframes dropPulse {
  from {
    transform: scale(0.8);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

.monster-image-container {
  width: 150px;
  height: 150px;
  margin: 0 auto 15px;
  border-radius: 12px;
  overflow: hidden;
  border: 3px solid #e74c3c;
  box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
}

.monster-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.inventory-section {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 2px solid #34495e;
}

.inventory-section h3 {
  margin: 0 0 15px 0;
  color: #2c3e50;
  font-size: 1.3em;
}

.inventory-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.equipped-items,
.unequipped-items {
  background: linear-gradient(135deg, #f8f9fa 0%, #ecf0f1 100%);
  padding: 15px;
  border-radius: 8px;
  border: 1px solid #bdc3c7;
}

.slot-title {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 10px;
  font-size: 0.95em;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.equipment-slots {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.slot-item {
  background: white;
  border: 2px solid #bdc3c7;
  border-radius: 6px;
  padding: 8px;
  min-height: 60px;
  display: flex;
  flex-direction: column;
}

.slot-name {
  font-size: 0.85em;
  color: #7f8c8d;
  font-weight: 500;
  margin-bottom: 4px;
}

.empty-slot {
  color: #95a5a6;
  font-style: italic;
  font-size: 0.9em;
  padding: 8px 0;
}

.equipped-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
  border-radius: 4px;
  padding: 6px;
  background-color: rgba(255, 255, 255, 0.5);
}

.equipped-item.rarity-common {
  border-left: 3px solid #95a5a6;
}

.equipped-item.rarity-uncommon {
  border-left: 3px solid #27ae60;
}

.equipped-item.rarity-rare {
  border-left: 3px solid #3498db;
}

.equipped-item.rarity-epic {
  border-left: 3px solid #9b59b6;
}

.equipped-item.rarity-legendary {
  border-left: 3px solid #f39c12;
}

.item-name {
  margin: 0;
  font-size: 0.9em;
  font-weight: 600;
  color: #2c3e50;
}

.item-type {
  margin: 0;
  font-size: 0.75em;
  color: #7f8c8d;
  text-transform: capitalize;
}

.stat {
  margin: 0;
  font-size: 0.8em;
  color: #27ae60;
  font-weight: 500;
}

.unequip-btn,
.equip-btn,
.delete-btn {
  padding: 4px 8px;
  font-size: 0.8em;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.2s;
  font-weight: 500;
}

.unequip-btn {
  margin-top: auto;
  background: #e74c3c;
  color: white;
}

.unequip-btn:hover {
  background: #c0392b;
}

.equip-btn {
  background: #27ae60;
  color: white;
}

.equip-btn:hover {
  background: #229954;
}

.delete-btn {
  background: #e67e22;
  color: white;
}

.delete-btn:hover {
  background: #d35400;
}

.item-actions {
  display: flex;
  gap: 4px;
  margin-top: auto;
}

.items-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 8px;
}

.inventory-item {
  background: white;
  border: 2px solid #bdc3c7;
  border-radius: 6px;
  padding: 8px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.inventory-item.rarity-common {
  border-color: #95a5a6;
  background: rgba(149, 165, 166, 0.05);
}

.inventory-item.rarity-uncommon {
  border-color: #27ae60;
  background: rgba(39, 174, 96, 0.05);
}

.inventory-item.rarity-rare {
  border-color: #3498db;
  background: rgba(52, 152, 219, 0.05);
}

.inventory-item.rarity-epic {
  border-color: #9b59b6;
  background: rgba(155, 89, 182, 0.05);
}

.inventory-item.rarity-legendary {
  border-color: #f39c12;
  background: rgba(243, 156, 18, 0.05);
}

.empty-inventory {
  padding: 20px;
  text-align: center;
  color: #95a5a6;
  font-style: italic;
}

.inventory-category {
  margin-bottom: 15px;
}

.category-header {
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 8px;
  font-size: 0.9em;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  padding-bottom: 6px;
  border-bottom: 1px solid #bdc3c7;
}

.auto-sell-panel {
  background: linear-gradient(135deg, #ecf0f1 0%, #d5dbdb 100%);
  border: 2px solid #34495e;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 20px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.panel-header h3 {
  margin: 0;
  font-size: 1.1em;
  color: #2c3e50;
}

.panel-close {
  background: #e74c3c;
  color: white;
  border: none;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 1em;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.2s;
}

.panel-close:hover {
  background: #c0392b;
}

.rarity-toggles {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 10px;
  margin-bottom: 15px;
}

.toggle-item {
  background: white;
  padding: 10px;
  border-radius: 6px;
  border: 1px solid #bdc3c7;
}

.toggle-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-weight: 500;
}

.toggle-checkbox {
  cursor: pointer;
  width: 18px;
  height: 18px;
}

.rarity-name {
  text-transform: capitalize;
  font-size: 0.9em;
  padding: 2px 6px;
  border-radius: 4px;
}

.rarity-name.rarity-common {
  color: #95a5a6;
  background: rgba(149, 165, 166, 0.1);
}

.rarity-name.rarity-uncommon {
  color: #27ae60;
  background: rgba(39, 174, 96, 0.1);
}

.rarity-name.rarity-rare {
  color: #3498db;
  background: rgba(52, 152, 219, 0.1);
}

.rarity-name.rarity-epic {
  color: #9b59b6;
  background: rgba(155, 89, 182, 0.1);
}

.rarity-name.rarity-legendary {
  color: #f39c12;
  background: rgba(243, 156, 18, 0.1);
}

.perform-auto-sell-btn {
  background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  width: 100%;
  transition: all 0.3s;
}

.perform-auto-sell-btn:hover {
  background: linear-gradient(135deg, #e67e22 0%, #d35400 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(230, 126, 34, 0.3);
}

.auto-sell-result {
  margin-top: 12px;
  padding: 10px;
  background: linear-gradient(135deg, #d5f4e6 0%, #a9dfbf 100%);
  border: 2px solid #27ae60;
  border-radius: 6px;
  color: #27ae60;
  text-align: center;
  font-weight: bold;
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    transform: translateY(-10px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

@media (max-width: 768px) {
  .inventory-container {
    grid-template-columns: 1fr;
  }

  .items-grid {
    grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  }

  .rarity-toggles {
    grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  }
}

.story-modal-overlay {
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

.story-modal {
  background: linear-gradient(135deg, #ffffff 0%, #f5f7fa 100%);
  border-radius: 16px;
  padding: 30px;
  max-width: 600px;
  width: 100%;
  max-height: 80vh;
  overflow-y: auto;
  box-shadow: 0 12px 48px rgba(0, 0, 0, 0.4);
}

.story-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  border-bottom: 2px solid #34495e;
  padding-bottom: 15px;
}

.story-header h2 {
  margin: 0;
  font-size: 1.6em;
  color: #2c3e50;
}

.story-close {
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

.story-close:hover {
  background: #c0392b;
}

.story-content {
  color: #2c3e50;
  line-height: 1.8;
}

.story-content p {
  margin: 15px 0;
  font-size: 1em;
  text-align: justify;
}

.story-content p:first-child {
  margin-top: 0;
}

.story-content p:last-child {
  margin-bottom: 0;
}

.story-mode-btn {
  background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 6px;
  font-weight: 600;
  font-size: 1em;
  cursor: pointer;
  transition: all 0.3s;
  margin-top: 20px;
}

.story-mode-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(39, 174, 96, 0.3);
  background: linear-gradient(135deg, #229954 0%, #1e8449 100%);
}

</style>
