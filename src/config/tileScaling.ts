export const SCALING_FACTOR = 1.4;

export const tileScaling: Record<number, {
  basePrice: number;
  revenuePerSec: number;
  upgradePrice: number;
}> = {
  1: {
    basePrice: 10,
    revenuePerSec: 0.1,
    upgradePrice: 50,
  },
  2: {
    basePrice: 14,
    revenuePerSec: 0.14,
    upgradePrice: 70,
  },
  3: {
    basePrice: 20,
    revenuePerSec: 0.2,
    upgradePrice: 98,
  },
  4: {
    basePrice: 28,
    revenuePerSec: 0.28,
    upgradePrice: 137,
  },
  5: {
    basePrice: 39,
    revenuePerSec: 0.39,
    upgradePrice: 192,
  },
  6: {
    basePrice: 55,
    revenuePerSec: 0.54,
    upgradePrice: 268,
  },
  7: {
    basePrice: 77,
    revenuePerSec: 0.76,
    upgradePrice: 375,
  },
  8: {
    basePrice: 108,
    revenuePerSec: 1.06,
    upgradePrice: 525,
  },
  9: {
    basePrice: 151,
    revenuePerSec: 1.49,
    upgradePrice: 735,
  },
  10: {
    basePrice: 211,
    revenuePerSec: 2.08,
    upgradePrice: 1029,
  },
};

export const getTileStats = (level: number) => {
  return tileScaling[Math.min(level, 10)] || tileScaling[10];
};
