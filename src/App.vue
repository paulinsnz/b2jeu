<script setup lang="ts">
import { ref, onMounted } from 'vue'
import MergeGame from './components/MergeGame.vue'
import Auth from './components/Auth.vue'
import { getCurrentUser, onAuthStateChange, signOut } from './services/authService'

const user = ref<any>(null)
const loading = ref(true)

onMounted(() => {
  onAuthStateChange((currentUser) => {
    user.value = currentUser
    loading.value = false
  })

  getCurrentUser().then(currentUser => {
    user.value = currentUser
    loading.value = false
  })
})

const handleSignOut = async () => {
  await signOut()
  user.value = null
}
</script>

<template>
  <div v-if="loading" class="loading">Chargement...</div>
  <div v-else-if="!user" class="auth-wrapper">
    <Auth @authenticated="user = $event" />
  </div>
  <div v-else class="game-wrapper">
    <div class="user-header">
      <span>Joueur: {{ user.email }}</span>
      <button @click="handleSignOut" class="sign-out-btn">Déconnexion</button>
    </div>
    <MergeGame />
  </div>
</template>

<style scoped>
.loading {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  font-size: 1.5em;
  color: #2c3e50;
  background: linear-gradient(135deg, #f5f7fa 0%, #ecf0f1 100%);
}

.auth-wrapper {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #ecf0f1 100%);
}

.game-wrapper {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, #f5f7fa 0%, #ecf0f1 100%);
}

.user-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  padding: 16px 30px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  gap: 20px;
}

.user-header span {
  font-weight: 600;
  font-size: 1.1em;
  flex: 1;
}

.sign-out-btn {
  background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-size: 1em;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 2px 8px rgba(231, 76, 60, 0.2);
}

.sign-out-btn:hover {
  background: linear-gradient(135deg, #c0392b 0%, #a93226 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
}

.sign-out-btn:active {
  transform: translateY(0);
}

@media (max-width: 768px) {
  .user-header {
    flex-direction: column;
    gap: 12px;
    text-align: center;
    padding: 12px 20px;
  }

  .user-header span {
    font-size: 1em;
  }

  .sign-out-btn {
    width: 100%;
  }
}
</style>
