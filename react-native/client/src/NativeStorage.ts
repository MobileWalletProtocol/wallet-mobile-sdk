import CoinbaseWalletSDK from "./CoinbaseWalletSDKModule";

export default {
  set(key: string, value: string) {
    CoinbaseWalletSDK.setValue(key, value);
  },
  getString(key: string): string | undefined {
    return CoinbaseWalletSDK.getValue(key) ?? undefined;
  },
  delete(key: string) {
    CoinbaseWalletSDK.deleteValue(key);
  },
};
