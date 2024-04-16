import { useContext } from 'react';

import { MobileWalletProtocolContext } from './MobileWalletProtocolProvider';

export function useMobileWalletProtocolHost() {
  const context = useContext(MobileWalletProtocolContext);
  if (context === null) {
    throw new Error('No MobileWalletProtocolProvider found in view tree');
  }

  return context;
}
