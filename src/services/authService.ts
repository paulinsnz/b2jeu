import { supabase } from './supabase'

export async function getCurrentUser() {
  const { data: { session } } = await supabase.auth.getSession()
  return session?.user || null
}

export async function signUpWithEmail(email: string, password: string, playerName: string) {
  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password
    })

    if (error) {
      return { success: false, error: error.message }
    }

    if (data.user) {
      await supabase
        .from('players')
        .insert({
          id: data.user.id,
          player_name: playerName
        })
        .maybeSingle()
    }

    return { success: true, user: data.user }
  } catch (err: any) {
    return { success: false, error: err.message }
  }
}

export async function signInWithEmail(email: string, password: string) {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    })

    if (error) {
      return { success: false, error: error.message }
    }

    return { success: true, user: data.user }
  } catch (err: any) {
    return { success: false, error: err.message }
  }
}

export async function signOut() {
  try {
    const { error } = await supabase.auth.signOut()
    if (error) {
      return { success: false, error: error.message }
    }
    return { success: true }
  } catch (err: any) {
    return { success: false, error: err.message }
  }
}

export function onAuthStateChange(callback: (user: any) => void) {
  return supabase.auth.onAuthStateChange((_event, session) => {
    callback(session?.user || null)
  })
}
