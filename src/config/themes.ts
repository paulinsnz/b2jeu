export type ThemeType = 'default' | 'brown'

export interface ThemeConfig {
  name: string
  boardBackgroundColor: string
  cellBackgroundColor: string
  gameHeaderColor: string
  statItemBackground: string
  statItemBorder: string
  xpBarBackground: string
  xpFillGradient: string
}

export const themes: Record<ThemeType, ThemeConfig> = {
  default: {
    name: 'Default',
    boardBackgroundColor: '#bdc3c7',
    cellBackgroundColor: '#ecf0f1',
    gameHeaderColor: '#2c3e50',
    statItemBackground: 'rgba(52, 152, 219, 0.1)',
    statItemBorder: '#3498db',
    xpBarBackground: '#ecf0f1',
    xpFillGradient: 'linear-gradient(90deg, #3498db 0%, #9b59b6 100%)',
  },
  brown: {
    name: 'Brown',
    boardBackgroundColor: '#8B6F47',
    cellBackgroundColor: '#D2B48C',
    gameHeaderColor: '#5D4E37',
    statItemBackground: 'rgba(139, 111, 71, 0.1)',
    statItemBorder: '#8B6F47',
    xpBarBackground: '#D2B48C',
    xpFillGradient: 'linear-gradient(90deg, #8B6F47 0%, #A0826D 100%)',
  }
}

export const themeSpecialCodes: Record<string, ThemeType> = {
  'BROWNMODE': 'brown',
  'THEME_BROWN': 'brown',
  'NORMAL': 'default',
  'NORMALMODE': 'default',
}
