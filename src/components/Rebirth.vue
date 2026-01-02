<template>
  <div v-if="isOpen" class="rebirth-modal-overlay" @click.self="closeRebirth">
    <div class="rebirth-modal">
      <div class="modal-header">
        <h2>Renassance</h2>
        <button @click="closeRebirth" class="close-btn">✕</button>
      </div>

      <div class="modal-content">
        <div class="rebirth-info">
          <div class="info-card">
            <h3>Renassance Actuelles: {{ rebirthCount }}</h3>
            <p>Multiplicateur or: x{{ rebirthBonusGoldMultiplier.toFixed(2) }}</p>
            <p>Multiplicateur fusion: x{{ rebirthBonusMergeMultiplier.toFixed(2) }}</p>
          </div>

          <div class="benefit-card">
            <h3>Prochaine Renassance Donnera:</h3>
            <div class="benefit-row">
              <span>Multiplicateur or supplémentaire:</span>
              <span class="gold">+0.05x</span>
            </div>
            <div class="benefit-row">
              <span>Multiplicateur fusion supplémentaire:</span>
              <span class="gold">+0.05x</span>
            </div>
            <div class="benefit-row">
              <span>Or bonus immédiat (5%):</span>
              <span class="gold">{{ Math.floor(currentGold * 0.05) }} 💵</span>
            </div>
          </div>

          <div class="warning-card">
            <h3>Avertissement</h3>
            <ul>
              <li>Toute votre progression du jeu sera complètement réinitialisée à 0</li>
              <li>Le plateau de jeu revient à la taille par défaut</li>
              <li>Tous les niveaux d'améliorations des tuiles seront réinitialisés</li>
              <li>Vous recevrez 5% de votre or actuel comme bonus initial</li>
              <li>Les multiplicateurs permanents du rebirth sont conservés</li>
              <li>Cette action ne peut pas être annulée</li>
            </ul>
          </div>
        </div>
      </div>

      <div class="modal-footer">
        <button @click="closeRebirth" class="cancel-btn">Annuler</button>
        <button @click="confirmRebirth" class="rebirth-btn">Confirmer la Renassance</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  isOpen: boolean
  currentGold: number
  rebirthCount: number
  rebirthBonusGoldMultiplier: number
  rebirthBonusMergeMultiplier: number
}

withDefaults(defineProps<Props>(), {
  isOpen: false,
  currentGold: 0,
  rebirthCount: 0,
  rebirthBonusGoldMultiplier: 1,
  rebirthBonusMergeMultiplier: 1
})

const emit = defineEmits<{
  close: []
  confirm: []
}>()

const closeRebirth = () => {
  emit('close')
}

const confirmRebirth = () => {
  const confirmed = confirm('Êtes-vous vraiment sûr? Cette action ne peut pas être annulée!')
  if (confirmed) {
    emit('confirm')
    closeRebirth()
  }
}
</script>

<style scoped>
.rebirth-modal-overlay {
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
  backdrop-filter: blur(4px);
}

.rebirth-modal {
  background: white;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
  max-width: 500px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 2px solid #f0f0f0;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.8em;
  color: #8e44ad;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5em;
  cursor: pointer;
  color: #7f8c8d;
  transition: color 0.2s;
}

.close-btn:hover {
  color: #2c3e50;
}

.modal-content {
  padding: 24px;
}

.rebirth-info {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-card,
.benefit-card,
.warning-card {
  padding: 16px;
  border-radius: 12px;
  background: #f8f9fa;
  border-left: 4px solid #8e44ad;
}

.benefit-card {
  border-left-color: #27ae60;
  background: rgba(39, 174, 96, 0.05);
}

.warning-card {
  border-left-color: #e74c3c;
  background: rgba(231, 76, 60, 0.05);
}

.info-card h3,
.benefit-card h3,
.warning-card h3 {
  margin: 0 0 12px 0;
  font-size: 1.1em;
  color: #2c3e50;
}

.benefit-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.benefit-row:last-child {
  border-bottom: none;
}

.benefit-row .gold {
  color: #f39c12;
  font-weight: bold;
  font-size: 1.1em;
}

.warning-card ul {
  margin: 0;
  padding-left: 20px;
  color: #2c3e50;
}

.warning-card li {
  margin: 8px 0;
  line-height: 1.6;
}

.modal-footer {
  display: flex;
  gap: 12px;
  padding: 24px;
  border-top: 2px solid #f0f0f0;
  background: #f8f9fa;
}

.cancel-btn,
.rebirth-btn {
  flex: 1;
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 1em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.cancel-btn {
  background: #95a5a6;
  color: white;
}

.cancel-btn:hover {
  background: #7f8c8d;
  transform: translateY(-2px);
}

.rebirth-btn {
  background: linear-gradient(135deg, #8e44ad 0%, #9b59b6 100%);
  color: white;
}

.rebirth-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(142, 68, 173, 0.4);
}

@media (max-width: 600px) {
  .rebirth-modal {
    width: 95%;
    max-height: 95vh;
  }

  .modal-header,
  .modal-content,
  .modal-footer {
    padding: 16px;
  }

  .modal-header h2 {
    font-size: 1.5em;
  }

  .benefit-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}
</style>
