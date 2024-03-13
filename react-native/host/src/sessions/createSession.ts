import type { HandshakeAction } from '../action/action';
import { MWPHostModule } from '../native-module/MWPHostNativeModule';
import type { RequestMessage } from '../request/request';
import type { AppMetadata } from '../utils/fetchClientAppMetadata';
import type { Session } from './sessions';

export async function createSession(
  metadata: AppMetadata,
  action: HandshakeAction,
  message: RequestMessage,
): Promise<Session> {
  const kp = await MWPHostModule.generateKeyPair();
  const now = new Date().toISOString();

  return {
    dappURL: action.callback,
    dappId: metadata.appId,
    dappName: metadata.appName ?? metadata.appId,
    dappImageURL: metadata.iconUrl,
    dappBase64Image: metadata.iconBase64Encoded,
    sessionId: message.uuid,
    version: message.version,
    clientPublicKey: message.sender,
    sessionPublicKey: kp.publicKey,
    sessionPrivateKey: kp.privateKey,
    generationTime: now,
    lastAccessTime: now,
  };
}
