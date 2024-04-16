import { EthereumAction, supportedEthereumMethods } from './ethereum';

export type HandshakeAction = {
  kind: 'handshake';
  appId: string;
  callback: string;
  appName?: string;
  appIconUrl?: string;
};

export type RequestAction = {
  id: number;
  kind: 'request';
  method: string;
  params: Record<string, unknown>;
  optional: boolean;
};

export type EthereumRequestAction = EthereumAction & {
  id: number;
  kind: 'request';
  optional: boolean;
};

export type Action = HandshakeAction | RequestAction | EthereumRequestAction;

export function isHandshakeAction(action: Action): action is HandshakeAction {
  return action.kind === 'handshake';
}

export function isEthereumAction(action: Action): action is EthereumRequestAction {
  return action.kind === 'request' && supportedEthereumMethods.includes(action.method);
}
