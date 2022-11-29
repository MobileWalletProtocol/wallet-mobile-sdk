export type ConfigurationParams = {
  callbackURL: URL;
  hostURL?: URL;
  hostPackageName?: string;
};

export type Action = {
  method: string;
  params: any;
  optional?: boolean;
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

export type Wallet = {
  name: string;
  iconUrl?: string;
  url?: string;
  mwpScheme?: string;
  appStoreUrl?: string;
  packageName?: string;
};
