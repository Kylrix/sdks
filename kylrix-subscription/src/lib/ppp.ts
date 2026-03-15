export type SubscriptionTier = 'PRO' | 'ULTRA' | 'ENTERPRISE';
export type PaymentMethod = 'CRYPTO' | 'CARD';

export interface RegionConfig {
  countryCode: string;
  name: string;
  currencySymbol: string;
  pppMultiplier: number;
}

export const PPP_CONFIG: Record<string, RegionConfig> = {
  US: { countryCode: 'US', name: 'United States', currencySymbol: '$', pppMultiplier: 1.0 },
  NG: { countryCode: 'NG', name: 'Nigeria', currencySymbol: '₦', pppMultiplier: 0.3 },
  IN: { countryCode: 'IN', name: 'India', currencySymbol: '₹', pppMultiplier: 0.4 },
  BR: { countryCode: 'BR', name: 'Brazil', currencySymbol: 'R$', pppMultiplier: 0.5 },
  GB: { countryCode: 'GB', name: 'United Kingdom', currencySymbol: '£', pppMultiplier: 0.9 },
  DE: { countryCode: 'DE', name: 'Germany', currencySymbol: '€', pppMultiplier: 0.9 },
  DEFAULT: { countryCode: 'US', name: 'Global', currencySymbol: '$', pppMultiplier: 1.0 }
};

export const BASE_PRICES: Record<SubscriptionTier, number> = {
  PRO: 10,
  ULTRA: 25,
  ENTERPRISE: 100
};

export const TIER_SECONDARY_MULTIPLIERS: Record<SubscriptionTier, number> = {
  PRO: 1.0,
  ULTRA: 1.5,
  ENTERPRISE: 2.5
};

export const SUBSCRIPTION_CONSTANTS = {
  CARD_MULTIPLIER: 1.25,
  CRYPTO_MULTIPLIER: 1.0,
};

export const calculateSubscriptionPrice = (
  tier: SubscriptionTier,
  countryCode: string,
  method: PaymentMethod
): number => {
  const region = PPP_CONFIG[countryCode] || PPP_CONFIG.DEFAULT;
  const basePrice = BASE_PRICES[tier];
  const regionalAdjustment = tier === 'PRO' ? region.pppMultiplier : 1.0;
  const secondaryMultiplier = TIER_SECONDARY_MULTIPLIERS[tier];
  const paymentMultiplier = method === 'CARD' 
    ? SUBSCRIPTION_CONSTANTS.CARD_MULTIPLIER 
    : SUBSCRIPTION_CONSTANTS.CRYPTO_MULTIPLIER;

  const finalPrice = ((basePrice * regionalAdjustment) * secondaryMultiplier) * paymentMultiplier;
  return Math.round(finalPrice * 100) / 100;
};
