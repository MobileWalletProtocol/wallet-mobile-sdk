import CoinbaseWalletSDK from "./CoinbaseWalletSDKModule";
import {
  Action,
  Account,
  ConfigurationParams,
  Result,
} from "./CoinbaseWalletSDK.types";

export {
  Action,
  Account,
  ConfigurationParams,
  Result,
} from "./CoinbaseWalletSDK.types";
export { WalletMobileSDKEVMProvider } from "./WalletMobileSDKEVMProvider";

export function configure({
  callbackURL,
  hostURL,
  hostPackageName,
}: ConfigurationParams) {
  CoinbaseWalletSDK.configure({
    callbackURL: callbackURL.toString(),
    hostURL: hostURL?.toString(),
    hostPackageName,
  });
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

  return await CoinbaseWalletSDK.initiateHandshake({ initialActions: actions });
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

  return await CoinbaseWalletSDK.makeRequest({
    actions: requestActions,
    account,
  });
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
