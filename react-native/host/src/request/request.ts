import type { Action, HandshakeAction, RequestAction } from '../action/action';

import type { BaseRequest, DecryptedRequestContent, HandshakeContent } from './decoding';

export type Account = {
  chain: string;
  networkId: number;
  address: string;
};

export type RequestMessage = {
  uuid: string;
  version: string;
  sender: string;
  callbackUrl: string;
  account?: Account;
  actions: Action[];
};

export function mapHandshakeToRequest(
  handshake: HandshakeContent,
  request: BaseRequest,
): RequestMessage {
  const handshakeAction: HandshakeAction = {
    kind: 'handshake',
    appId: handshake.appId,
    callback: handshake.callback,
  };

  const additionalActions: RequestAction[] =
    handshake.initialActions?.map(({ method, optional, paramsJson }, index) => ({
      id: index,
      kind: 'request',
      method,
      optional,
      params: JSON.parse(paramsJson) as Record<string, unknown>,
    })) ?? [];

  return {
    uuid: request.uuid,
    version: request.version,
    sender: request.sender,
    callbackUrl: request.callbackUrl,
    actions: [handshakeAction, ...additionalActions],
  };
}

export function mapDecryptedContentToRequest(
  request: DecryptedRequestContent,
  base: BaseRequest,
): RequestMessage {
  const actions: RequestAction[] = request.actions.map(
    ({ method, optional, paramsJson }, index) => ({
      id: index,
      kind: 'request',
      method,
      optional,
      params: JSON.parse(paramsJson) as Record<string, unknown>,
    }),
  );

  return {
    uuid: base.uuid,
    version: base.version,
    sender: base.sender,
    callbackUrl: base.callbackUrl,
    account: request.account,
    actions,
  };
}
