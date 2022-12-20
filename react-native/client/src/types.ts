import { Action } from "./action/action";

export { Action, EthereumRequestAction } from "./action/action";

export type ConfigurationParams = {
  callbackURL: URL;
  appID?: string;
  appName?: string;
  appIconURL?: string;
};

export type Account = {
  chain: string;
  networkId: number;
  address: string;
};

export type Result = {
  result?: string;
  errorCode?: number;
  errorMessage?: string;
};

export type WalletIdentifier =
  | {
      platform: "android";
      packageName: string;
    }
  | {
      platform: "ios";
      mwpScheme: string;
    };

export type Wallet = {
  name: string;
  iconUrl: string;
  url: string;
  appStoreUrl: string;
  id: WalletIdentifier;
};

export type Request = {
  actions: Action[];
  account?: Account;
};
