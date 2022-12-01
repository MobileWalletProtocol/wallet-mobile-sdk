import CoinbaseWalletSDK from "./CoinbaseWalletSDKModule";
import {
  Action,
  Account,
  ConfigurationParams,
  Result,
  Wallet,
} from "./CoinbaseWalletSDK.types";
import {WalletMobileSDKEVMProvider, WalletMobileSDKProviderOptions} from "./WalletMobileSDKEVMProvider";

export { WalletMobileSDKEVMProvider } from "./WalletMobileSDKEVMProvider";

export function configure({ callbackURL }: ConfigurationParams) {
  CoinbaseWalletSDK.configure(callbackURL.toString());
}

export async function initiateHandshake(
  initialActions?: Action[]
): Promise<[Result[], Account?]> {
  const actions =
    initialActions?.map((action) => {
      return {
        method: action.method,
        paramsJson: JSON.stringify(action.params),
        optional: action.optional ?? false,
      };
    }) ?? [];

  return await CoinbaseWalletSDK.initiateHandshake(actions);
}

export async function makeRequest(
  actions: Action[],
  account?: Account
): Promise<Result[]> {
  const requestActions = actions.map((action) => {
    return {
      method: action.method,
      paramsJson: JSON.stringify(action.params),
      optional: action.optional ?? false,
    };
  });

  return await CoinbaseWalletSDK.makeRequest(requestActions, account);
}

export function handleResponse(url: URL): boolean {
  return CoinbaseWalletSDK.handleResponse(url.toString());
}

export function isCoinbaseWalletInstalled(): boolean {
  return CoinbaseWalletSDK.isCoinbaseWalletInstalled();
}

export function isConnected(): boolean {
  return CoinbaseWalletSDK.isConnected();
}

export function resetSession() {
  CoinbaseWalletSDK.resetSession();
}

export function getWallets(): Wallet[] {
  return CoinbaseWalletSDK.getWallets();
}

export function connectWallet(wallet: Wallet) {
  CoinbaseWalletSDK.connectWallet(wallet);
}

export function getEvmProvider(wallet: Wallet, opts?: WalletMobileSDKProviderOptions) {
  return new WalletMobileSDKEVMProvider(opts);
}