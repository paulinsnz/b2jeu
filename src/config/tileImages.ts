import { brownTileImages } from './brownTileImages'
import type { ThemeType } from './themes'

export const tileImages: Record<number, string> = {
  1: 'https://image.noelshack.com/fichiers/2025/48/3/1764147088-adrien.jpg',
  2: 'https://image.noelshack.com/fichiers/2025/48/3/1764147140-romain.png',
  3: 'https://image.noelshack.com/fichiers/2025/48/3/1764147246-theomorchoisnes.jpg',
  4: 'https://image.noelshack.com/fichiers/2025/48/3/1764148526-theocauliez.png',
  5: 'https://image.noelshack.com/fichiers/2025/48/3/1764148540-nathan.png',
  6: 'https://image.noelshack.com/fichiers/2025/48/3/1764148558-tobias.jpg',
  7: 'https://image.noelshack.com/fichiers/2025/48/3/1764148569-maxencehego.jpg',
  8: 'https://image.noelshack.com/fichiers/2025/48/3/1764148587-tom.jpg',
  9: 'https://image.noelshack.com/fichiers/2025/48/3/1764148617-valentin.jpg',
  10: 'https://image.noelshack.com/fichiers/2025/48/3/1764148631-thomasmonniez.jpg',
  11: 'https://image.noelshack.com/fichiers/2025/48/3/1764148643-matteotroplong.png',
  12: 'https://image.noelshack.com/fichiers/2025/48/3/1764148665-alexandredomont.jpg',
  13: 'https://image.noelshack.com/fichiers/2025/48/3/1764148752-hugoiwaniec.jpg',
  14: 'https://image.noelshack.com/fichiers/2025/48/3/1764148766-kameto.png',
  15: 'https://image.noelshack.com/fichiers/2025/48/3/1764148775-jimmy.jpg',
  16: 'https://image.noelshack.com/fichiers/2025/48/3/1764148788-lucabona.jpg',
  17: 'https://image.noelshack.com/fichiers/2025/48/3/1764148804-maxencepierre.jpg',
  18: 'https://image.noelshack.com/fichiers/2025/48/3/1764148829-mathis.png',
  19: 'https://image.noelshack.com/fichiers/2025/48/3/1764148842-valentine.jpg',
  20: 'https://image.noelshack.com/fichiers/2025/48/3/1764148867-matteodelfiacco.png',
}

export const getTileImage = (level: number, theme: ThemeType = 'default'): string => {
  if (theme === 'brown') {
    return brownTileImages[level] || brownTileImages[1]
  }
  return tileImages[level] || tileImages[1]
}
