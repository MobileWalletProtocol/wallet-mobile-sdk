import { Linking, Platform } from 'react-native';

import { isHandshakeAction, RequestAction } from '../action/action';
import { MWPHostModule } from '../native-module/MWPHostNativeModule';
import type { RequestMessage } from '../request/request';
import {
  getSession,
  SecureStorage,
  updateSessions,
} from '../sessions/sessions';

export type ResultValue = {
  value: string;
};

export type ErrorValue = {
  message: string;
  code: number;
};

export type ReturnValue = { result: ResultValue } | { error: ErrorValue };

type SuccessResponse = {
  requestId: string;
  values: ReturnValue[];
};

type FailureResponse = {
  requestId: string;
  description: string;
};

type ResponseContent =
  | { response: SuccessResponse }
  | { failure: FailureResponse };

type ResponseMessage = {
  version: string;
  sender: string;
  timestamp: number;
  content: ResponseContent;
  uuid: string;
  callbackUrl: string;
};

// TODO: Move response encoding into native module and have separate function for encrypting
async function respond(
  response: ResponseMessage,
  callbackUrl: string,
  sessionPrivateKey?: string,
  clientPublicKey?: string
) {
  let encodedResponseUrl: string;

  if (sessionPrivateKey && clientPublicKey) {
    // Encrypted response
    const platformResponse =
      Platform.OS === 'android' ? JSON.stringify(response) : response;
    encodedResponseUrl = await MWPHostModule.encodeResponse(
      platformResponse,
      callbackUrl,
      sessionPrivateKey,
      clientPublicKey
    );
  } else {
    // Unencrypted response
    const url = new URL(callbackUrl);
    const encoded = Buffer.from(JSON.stringify(response)).toString('base64');
    url.searchParams.set('p', encoded);
    encodedResponseUrl = url.toString();
  }

  if (Platform.OS === 'android') {
    await MWPHostModule.triggerWalletSDKCallback(encodedResponseUrl);
  } else {
    await Linking.openURL(encodedResponseUrl);
  }
}

export async function sendResponse(
  responseMap: Map<number, ReturnValue>,
  message: RequestMessage,
  storage: SecureStorage
) {
  const actions = message.actions.filter(
    (value) => !isHandshakeAction(value)
  ) as RequestAction[];

  const responses: ReturnValue[] = actions.map((value) => {
    const returnValue = responseMap.get(value.id);
    if (returnValue) {
      responseMap.delete(value.id); // remove response from map
      return returnValue;
    }
    return {
      error: { code: 4001, message: 'skipped' },
    };
  });

  const session = await getSession(storage, message);
  if (!session) {
    throw new Error('No session found');
  }

  // Update session timestamp
  await updateSessions(storage, [
    {
      ...session,
      version: message.version,
      lastAccessTime: new Date().toISOString(),
    },
  ]);

  const response: ResponseMessage = {
    version: session.version ?? '0', // TODO: Should this be version of sdk in host library?
    sender: session.sessionPublicKey,
    uuid: session.sessionId, // TODO: Should this be a unique id?
    callbackUrl: session.dappURL,
    timestamp: Date.now(),
    content: {
      response: {
        requestId: message.uuid,
        values: responses,
      },
    },
  };

  await respond(
    response,
    session.dappURL,
    session.sessionPrivateKey,
    session.clientPublicKey
  );
}

export async function sendError(
  description: string,
  message: {
    version: string;
    sender: string;
    uuid: string;
    callbackUrl: string;
  }
) {
  const response: ResponseMessage = {
    version: message.version,
    sender: message.sender,
    uuid: message.uuid, // TODO: Should this be a unique uuid?
    callbackUrl: message.callbackUrl,
    timestamp: Date.now(),
    content: {
      failure: {
        requestId: message.uuid,
        description,
      },
    },
  };

  await respond(response, message.callbackUrl);
}

export function shouldRespondToClient(
  responseMap: Map<number, ReturnValue>,
  message: RequestMessage
): boolean {
  const actions = message.actions.filter((value) => !isHandshakeAction(value));
  return responseMap.size === actions.length;
}
