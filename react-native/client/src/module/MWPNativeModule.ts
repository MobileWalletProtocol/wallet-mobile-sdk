import { requireNativeModule } from "expo-modules-core";
import { Account, ConfigurationParams, Result, Wallet } from "../types";

type ActionRecord = {
  method: string;
  paramsJson: string;
  optional: boolean;
};

type RequestRecord = {
  actions: ActionRecord[];
  account?: Account;
};

type WalletRecord = {
  name: string;
  iconUrl: string;
  url: string;
  appStoreUrl: string;
  mwpScheme?: string;
  packageName?: string;
};

// Type hints for functions exposed by native layer
type MWPNativeModule = {
  configure: (config: ConfigurationParams) => void;
  handleResponse: (url: string) => boolean;
  getWallets: () => Wallet[];
  isConnected: (wallet: Wallet) => boolean;
  resetSession: (wallet: Wallet) => void;
  initiateHandshake: (
    wallet: Wallet,
    initialActions: ActionRecord[]
  ) => Promise<[Result[], Account?]>;
  makeRequest: (wallet: Wallet, request: RequestRecord) => Promise<Result[]>;
};

// It loads the native module object from the JSI or falls back to
// the bridge module (from NativeModulesProxy) if the remote debugger is on.
export default requireNativeModule("CoinbaseWalletSDK") as MWPNativeModule;
