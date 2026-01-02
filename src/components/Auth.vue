<template>
  <div class="auth-container">
    <div class="auth-modal">
      <h2>{{ isSignUp ? 'Créer un compte' : 'Se connecter' }}</h2>

      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label for="email">Email:</label>
          <input
            v-model="email"
            id="email"
            type="email"
            required
            placeholder="votre@email.com"
          />
        </div>

        <div v-if="isSignUp" class="form-group">
          <label for="playerName">Pseudo (3-20 caractères):</label>
          <input
            v-model="playerName"
            id="playerName"
            type="text"
            required
            minlength="3"
            maxlength="20"
            placeholder="Votre pseudo"
          />
        </div>

        <div class="form-group">
          <label for="password">Mot de passe:</label>
          <input
            v-model="password"
            id="password"
            type="password"
            required
            placeholder="••••••••"
          />
        </div>

        <button type="submit" class="submit-btn" :disabled="loading">
          {{ loading ? 'Chargement...' : (isSignUp ? 'Créer un compte' : 'Se connecter') }}
        </button>
      </form>

      <div v-if="error" class="error">{{ error }}</div>

      <button @click="isSignUp = !isSignUp" class="toggle-btn">
        {{ isSignUp ? 'Déjà inscrit ? Se connecter' : 'Pas de compte ? Créer un compte' }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { signUpWithEmail, signInWithEmail } from '../services/authService'

const emit = defineEmits<{
  authenticated: [user: any]
}>()

const email = ref('')
const password = ref('')
const playerName = ref('')
const isSignUp = ref(false)
const loading = ref(false)
const error = ref('')

const handleSubmit = async () => {
  loading.value = true
  error.value = ''

  try {
    if (isSignUp.value) {
      if (!playerName.value || playerName.value.length < 3 || playerName.value.length > 20) {
        error.value = 'Le pseudo doit contenir entre 3 et 20 caractères'
        loading.value = false
        return
      }
      const result = await signUpWithEmail(email.value, password.value, playerName.value)
      if (result.success) {
        emit('authenticated', result.user)
      } else {
        error.value = result.error || 'Erreur lors de la création du compte'
      }
    } else {
      const result = await signInWithEmail(email.value, password.value)
      if (result.success) {
        emit('authenticated', result.user)
      } else {
        error.value = result.error || 'Erreur lors de la connexion'
      }
    }
  } catch (err: any) {
    error.value = err.message || 'Une erreur est survenue'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.auth-modal {
  background: white;
  padding: 40px;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 400px;
}

.auth-modal h2 {
  margin: 0 0 30px 0;
  text-align: center;
  color: #2c3e50;
  font-size: 1.8em;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  color: #2c3e50;
  font-weight: 600;
}

.form-group input {
  width: 100%;
  padding: 12px;
  border: 2px solid #ecf0f1;
  border-radius: 8px;
  font-size: 1em;
  transition: border-color 0.3s;
  box-sizing: border-box;
}

.form-group input:focus {
  outline: none;
  border-color: #667eea;
}

.submit-btn {
  width: 100%;
  padding: 12px;
  background-color: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1.1em;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.3s;
}

.submit-btn:hover:not(:disabled) {
  background-color: #5568d3;
}

.submit-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error {
  color: #e74c3c;
  margin: 20px 0;
  padding: 12px;
  background-color: #fadbd8;
  border-radius: 8px;
  text-align: center;
}

.toggle-btn {
  width: 100%;
  padding: 12px;
  margin-top: 20px;
  background-color: transparent;
  color: #667eea;
  border: 2px solid #667eea;
  border-radius: 8px;
  font-size: 1em;
  cursor: pointer;
  transition: all 0.3s;
}

.toggle-btn:hover {
  background-color: #667eea;
  color: white;
}
</style>
