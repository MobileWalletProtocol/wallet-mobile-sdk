import MWPNativeModule from "./MWPNativeModule";
import {
  Action,
  Account,
  ConfigurationParams,
  Result,
  Wallet,
  Request,
} from "../types";

export function configure(params: ConfigurationParams) {
  MWPNativeModule.configure(params);
}

export function handleResponse(url: URL): boolean {
  return MWPNativeModule.handleResponse(url.toString());
}

export function getWallets(): Wallet[] {
  return MWPNativeModule.getWallets();
}

export function isWalletConnected(wallet: Wallet): boolean {
  return MWPNativeModule.isConnected(wallet);
}

export function isWalletInstalled(wallet: Wallet): boolean {
  return MWPNativeModule.isInstalled(wallet);
}

export function resetSession(wallet: Wallet) {
  MWPNativeModule.resetSession(wallet);
}

export async function initiateHandshake(
  wallet: Wallet,
  initialActions?: Action[]
): Promise<[Result[], Account?]> {
  const actions = initialActions?.map(actionToRecord) ?? [];
  return await MWPNativeModule.initiateHandshake({
    wallet,
    initialActions: actions,
  });
}

export async function makeRequest(
  wallet: Wallet,
  { actions, account }: Request
): Promise<Result[]> {
  const requestRecord = {
    actions: actions.map(actionToRecord),
    account,
  };

  return await MWPNativeModule.makeRequest({ wallet, request: requestRecord });
}

function actionToRecord(action: Action) {
  return {
    method: action.method,
    paramsJson: JSON.stringify(action.params),
    optional: action.optional,
  };
}
