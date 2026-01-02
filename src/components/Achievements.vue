<template>
  <div class="achievements-overlay" @click.self="close">
    <div class="achievements-modal">
      <div class="modal-header">
        <h2>Achievements</h2>
        <button @click="close" class="close-btn">✕</button>
      </div>

      <div class="achievements-grid">
        <div
          v-for="achievement in achievements"
          :key="achievement.id"
          class="achievement-card"
          :class="{ unlocked: achievement.unlocked }"
        >
          <div class="achievement-icon">{{ achievement.icon }}</div>
          <div class="achievement-info">
            <h3>{{ achievement.name }}</h3>
            <p>{{ achievement.description }}</p>
            <div class="achievement-progress" v-if="!achievement.unlocked">
              <div class="progress-bar">
                <div
                  class="progress-fill"
                  :style="{ width: `${(achievement.current / achievement.target) * 100}%` }"
                ></div>
              </div>
              <span class="progress-text">{{ achievement.current }} / {{ achievement.target }}</span>
            </div>
            <div class="achievement-status" v-else>
              Débloqué!
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Achievement {
  id: string
  name: string
  description: string
  icon: string
  unlocked: boolean
  current: number
  target: number
}

defineProps<{
  achievements: Achievement[]
}>()

const emit = defineEmits<{
  close: []
}>()

const close = () => {
  emit('close')
}
</script>

<style scoped>
.achievements-overlay {
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

.achievements-modal {
  background: linear-gradient(135deg, #ffffff 0%, #f5f7fa 100%);
  border-radius: 16px;
  max-width: 900px;
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

.achievements-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  padding: 30px;
}

.achievement-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  gap: 15px;
  border: 2px solid #bdc3c7;
  transition: all 0.3s;
  opacity: 0.6;
}

.achievement-card.unlocked {
  border-color: #27ae60;
  opacity: 1;
  box-shadow: 0 4px 12px rgba(39, 174, 96, 0.2);
}

.achievement-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
}

.achievement-icon {
  font-size: 3em;
  flex-shrink: 0;
}

.achievement-info {
  flex-grow: 1;
}

.achievement-info h3 {
  margin: 0 0 8px 0;
  font-size: 1.2em;
  color: #2c3e50;
}

.achievement-info p {
  margin: 0 0 10px 0;
  font-size: 0.9em;
  color: #7f8c8d;
  line-height: 1.4;
}

.achievement-progress {
  margin-top: 10px;
}

.progress-bar {
  background: #ecf0f1;
  border-radius: 8px;
  height: 8px;
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
  font-size: 0.85em;
  color: #7f8c8d;
  font-weight: 600;
}

.achievement-status {
  color: #27ae60;
  font-weight: bold;
  font-size: 1em;
  margin-top: 10px;
}
</style>
