export type RequestAccountsAction = {
  method: 'eth_requestAccounts';
  params: Record<string, never>; // empty object
};

export type PersonalSignAction = {
  method: 'personal_sign';
  params: {
    address: string;
    message: string;
  };
};

export type SignTypedDataV3Action = {
  method: 'eth_signTypedData_v3';
  params: {
    address: string;
    typedDataJson: string;
  };
};

export type SignTypedDataV4Action = {
  method: 'eth_signTypedData_v4';
  params: {
    address: string;
    typedDataJson: string;
  };
};

export type SignTransactionAction = {
  method: 'eth_signTransaction';
  params: {
    fromAddress: string;
    toAddress: string | null;
    weiValue: string;
    data: string;
    nonce: number;
    gasPriceInWei: string | null;
    maxFeePerGas: string | null;
    maxPriorityFeePerGas: string | null;
    gasLimit: string | null;
    chainId: string;
  };
};

export type SendTransactionAction = {
  method: 'eth_sendTransaction';
  params: {
    fromAddress: string;
    toAddress: string | null;
    weiValue: string;
    data: string;
    nonce: number;
    gasPriceInWei: string | null;
    maxFeePerGas: string | null;
    maxPriorityFeePerGas: string | null;
    gasLimit: string | null;
    chainId: string;
    actionSource?: {
      url: string;
    } | null;
  };
};

export type SwitchEthereumChainAction = {
  method: 'wallet_switchEthereumChain';
  params: {
    chainId: string;
  };
};

export type AddEthereumChainAction = {
  method: 'wallet_addEthereumChain';
  params: {
    chainId: string;
    blockExplorerUrls: string[] | null;
    chainName: string | null;
    iconUrls: string[] | null;
    nativeCurrency: {
      name: string;
      symbol: string;
      decimals: number;
    };
    rpcUrls: string[];
  };
};

export type WatchAssetAction = {
  method: 'wallet_watchAsset';
  params: {
    type: string;
    options: {
      address: string;
      symbol: string | null;
      decimals: number | null;
      image: string | null;
    };
  };
};

export type EthereumAction =
  | RequestAccountsAction
  | PersonalSignAction
  | SignTypedDataV3Action
  | SignTypedDataV4Action
  | SignTransactionAction
  | SendTransactionAction
  | SwitchEthereumChainAction
  | AddEthereumChainAction
  | WatchAssetAction;

export const supportedEthereumMethods = [
  'eth_requestAccounts',
  'personal_sign',
  'eth_signTypedData_v3',
  'eth_signTypedData_v4',
  'eth_signTransaction',
  'eth_sendTransaction',
  'wallet_switchEthereumChain',
  'wallet_addEthereumChain',
  'wallet_watchAsset',
];
