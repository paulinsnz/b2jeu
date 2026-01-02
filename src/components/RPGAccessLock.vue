<template>
  <div class="rpg-lock-overlay">
    <div class="lock-container">
      <div class="lock-header">
        <h2>🔐 Accès au Monde RPG Verrouillé</h2>
        <p class="lock-message">Entrez le code secret pour accéder au monde RPG</p>
      </div>
      <div class="lock-form">
        <input
          v-model="inputCode"
          type="password"
          placeholder="Code secret..."
          class="code-input"
          @keyup.enter="attemptAccess"
          :class="{ error: showError }"
        />
        <button @click="attemptAccess" class="unlock-btn">
          Déverrouiller
        </button>
        <div v-if="showError" class="error-message">
          Code incorrect. Veuillez réessayer.
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const props = defineProps<{
  correctCode: string
}>()

const emit = defineEmits<{
  unlocked: []
}>()

const inputCode = ref('')
const showError = ref(false)

const attemptAccess = () => {
  if (inputCode.value === props.correctCode) {
    inputCode.value = ''
    showError.value = false
    emit('unlocked')
  } else {
    showError.value = true
    inputCode.value = ''
    setTimeout(() => {
      showError.value = false
    }, 2000)
  }
}
</script>

<style scoped>
.rpg-lock-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(0, 0, 0, 0.8) 0%, rgba(44, 62, 80, 0.8) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  backdrop-filter: blur(4px);
}

.lock-container {
  background: linear-gradient(135deg, #ffffff 0%, #f5f7fa 100%);
  border-radius: 20px;
  padding: 40px;
  max-width: 500px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
  animation: slideUp 0.4s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(30px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.lock-header {
  text-align: center;
  margin-bottom: 30px;
}

.lock-header h2 {
  margin: 0 0 10px 0;
  font-size: 1.8em;
  color: #2c3e50;
  font-weight: 700;
}

.lock-message {
  margin: 0;
  color: #7f8c8d;
  font-size: 1em;
  line-height: 1.5;
}

.lock-form {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.code-input {
  padding: 14px 16px;
  border: 2px solid #bdc3c7;
  border-radius: 10px;
  font-size: 1em;
  font-family: inherit;
  transition: all 0.3s;
  background: #fafbfc;
}

.code-input:focus {
  outline: none;
  border-color: #3498db;
  background: white;
  box-shadow: 0 0 0 4px rgba(52, 152, 219, 0.1);
}

.code-input.error {
  border-color: #e74c3c;
  background: rgba(231, 76, 60, 0.05);
  animation: shake 0.3s ease-in-out;
}

@keyframes shake {
  0%, 100% {
    transform: translateX(0);
  }
  25% {
    transform: translateX(-5px);
  }
  75% {
    transform: translateX(5px);
  }
}

.unlock-btn {
  padding: 14px 24px;
  background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1em;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.unlock-btn:hover {
  background: linear-gradient(135deg, #229954 0%, #1e8449 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(39, 174, 96, 0.3);
}

.unlock-btn:active {
  transform: translateY(0);
}

.error-message {
  padding: 12px;
  background: linear-gradient(135deg, #fadbd8 0%, #f5b7b1 100%);
  border: 2px solid #e74c3c;
  border-radius: 8px;
  color: #c0392b;
  text-align: center;
  font-weight: 600;
  font-size: 0.95em;
  animation: fadeIn 0.3s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-5px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (max-width: 480px) {
  .lock-container {
    padding: 30px 20px;
    margin: 20px;
  }

  .lock-header h2 {
    font-size: 1.5em;
  }

  .lock-message {
    font-size: 0.95em;
  }
}
</style>
