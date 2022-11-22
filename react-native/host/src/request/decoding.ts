import { diagnosticLog } from '../events/events';
import { MWPHostModule } from '../native-module/MWPHostNativeModule';
import type { Session } from '../sessions/sessions';
import { URL } from 'react-native-url-polyfill';
import { Buffer } from 'buffer';

export type BaseRequest = {
  version: string;
  sender: string;
  uuid: string;
  callbackUrl: string;
};

export type HandshakeContent = {
  // TODO: Handle additional handshake params
  appId: string;
  callback: string;
  initialActions?: { method: string; optional: boolean; paramsJson: string }[];
};

export type EncryptedRequestContent = {
  data: string;
};

export type DecryptedRequestContent = {
  account: {
    chain: string;
    networkId: number;
    address: string;
  };
  actions: { method: string; optional: boolean; paramsJson: string }[];
};

export type DecodedRequest = BaseRequest & {
  content: { request: EncryptedRequestContent } | { handshake: HandshakeContent };
};

type DecryptedRequest = BaseRequest & {
  content: { request: DecryptedRequestContent };
};

// TODO: Move decoding to native module
export async function decodeRequest(url: string): Promise<DecodedRequest | null> {
  try {
    const base64EncodedRequest = new URL(url).searchParams.get('p');
    if (base64EncodedRequest === null) {
      return null;
    }

    const jsonString = Buffer.from(base64EncodedRequest, 'base64').toString('ascii');
    return JSON.parse(jsonString) as DecodedRequest;
  } catch (e) {
    return null;
  }
}

// TODO: Implement `decryptRequest` in native module
export async function decryptRequest(url: string, session: Session): Promise<DecryptedRequest> {
  const { dappURL, version } = session;

  diagnosticLog({
    name: 'decrypt_request_start',
    params: { callbackUrl: dappURL, sdkVersion: version ?? '0' },
  });

  try {
    const decrypted = await MWPHostModule.decodeRequest(
      url,
      session.sessionPrivateKey,
      session.clientPublicKey,
    );

    diagnosticLog({
      name: 'decrypt_request_success',
      params: { callbackUrl: dappURL, sdkVersion: version ?? '0' },
    });

    return decrypted as DecryptedRequest;
  } catch (e) {
    diagnosticLog({
      name: 'decrypt_request_failure',
      params: {
        error: (e as Error).message,
        callbackUrl: session.dappURL,
        sdkVersion: session.version ?? '0',
      },
    });

    throw e;
  }
}
