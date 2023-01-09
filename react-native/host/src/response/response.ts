import { Linking, Platform } from 'react-native';
import { diagnosticLog, ResponseEventParams } from '../events/events';
import type { DecodedRequest } from '../request/decoding';

import { isHandshakeAction, RequestAction } from '../action/action';
import { MWPHostModule } from '../native-module/MWPHostNativeModule';
import type { RequestMessage } from '../request/request';
import { getSession, SecureStorage, updateSessions } from '../sessions/sessions';
import { uuidV4 } from '../utils/uuid';
import { URL } from 'react-native-url-polyfill';
import { Buffer } from 'buffer';

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

type ResponseContent = { response: SuccessResponse } | { failure: FailureResponse };

type ResponseMessage = {
  version: string;
  sender: string;
  timestamp: number;
  content: ResponseContent;
  uuid: string;
  callbackUrl: string;
};

type RequestType = 'handshake' | 'request';

type TypedResponseEventParams = ResponseEventParams & { requestType: RequestType };

type EventParams =
  | {
      type: 'success';
      params: TypedResponseEventParams;
    }
  | {
      type: 'failure';
      params: TypedResponseEventParams & { error: string };
    };

type RespondParams = {
  response: ResponseMessage;
  callbackUrl: string;
  sessionPrivateKey?: string;
  clientPublicKey?: string;
  eventParams: EventParams;
};

function getRequestType(request: RequestMessage | DecodedRequest): RequestType {
  if ('content' in request) {
    // DecodedRequest
    if ('handshake' in request.content) {
      return 'handshake';
    } else {
      return 'request';
    }
  } else {
    // RequestMessage
    const first = request.actions[0];
    return first?.kind ?? 'request';
  }
}

// TODO: Move response encoding into native module and have separate function for encrypting
async function respond({
  response,
  callbackUrl,
  sessionPrivateKey,
  clientPublicKey,
  eventParams,
}: RespondParams) {
  diagnosticLog({
    name: 'encode_response_start',
    params: eventParams.params,
  });

  let encodedResponseUrl: string;
  if (sessionPrivateKey && clientPublicKey) {
    // Encrypted response
    const platformResponse = Platform.OS === 'android' ? JSON.stringify(response) : response;
    encodedResponseUrl = await MWPHostModule.encodeResponse(
      platformResponse,
      callbackUrl,
      sessionPrivateKey,
      clientPublicKey,
    );
  } else {
    // Unencrypted response
    const url = new URL(callbackUrl);
    const encoded = Buffer.from(JSON.stringify(response)).toString('base64');
    url.searchParams.set('p', encoded);
    encodedResponseUrl = url.toString();
  }

  diagnosticLog({
    name: 'encode_response_success',
    params: eventParams.params,
  });

  switch (eventParams.type) {
    case 'success':
      diagnosticLog({
        name: 'send_success_response',
        params: eventParams.params,
      });
      break;
    case 'failure':
      diagnosticLog({
        name: 'send_failure_response',
        params: eventParams.params,
      });
      break;
  }

  diagnosticLog({
    name: 'response_handled',
    params: eventParams.params,
  });

  if (Platform.OS === 'android') {
    await MWPHostModule.triggerWalletSDKCallback(encodedResponseUrl);
  } else {
    await Linking.openURL(encodedResponseUrl);
  }
}

export async function sendResponse(
  responseMap: Map<number, ReturnValue>,
  message: RequestMessage,
  storage: SecureStorage,
) {
  const actions = message.actions.filter((value) => !isHandshakeAction(value)) as RequestAction[];

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

  const sdkVersion = await MWPHostModule.getSdkVersion();

  const response: ResponseMessage = {
    version: sdkVersion,
    sender: session.sessionPublicKey,
    uuid: uuidV4(),
    callbackUrl: session.dappURL,
    timestamp: Date.now(),
    content: {
      response: {
        requestId: message.uuid,
        values: responses,
      },
    },
  };

  const eventParams: EventParams = {
    type: 'success',
    params: {
      requestType: getRequestType(message),
      appId: session.dappId,
      appName: session.dappName,
      callbackUrl: session.dappURL,
      sdkVersion: session.version ?? '0',
    },
  };

  try {
    await respond({
      response,
      callbackUrl: session.dappURL,
      sessionPrivateKey: session.sessionPrivateKey,
      clientPublicKey: session.clientPublicKey,
      eventParams,
    });
  } catch (e) {
    diagnosticLog({
      name: 'encode_response_failure',
      params: {
        ...eventParams.params,
        error: (e as Error).message,
      },
    });

    throw e;
  }
}

export async function sendError(description: string, message: RequestMessage | DecodedRequest) {
  const sdkVersion = await MWPHostModule.getSdkVersion();

  const response: ResponseMessage = {
    version: sdkVersion,
    sender: message.sender,
    uuid: uuidV4(),
    callbackUrl: message.callbackUrl,
    timestamp: Date.now(),
    content: {
      failure: {
        requestId: message.uuid,
        description,
      },
    },
  };

  const eventParams: EventParams = {
    type: 'failure',
    params: {
      requestType: getRequestType(message),
      appId: 'unknown',
      appName: 'unknown',
      error: description,
      callbackUrl: message.callbackUrl,
      sdkVersion: message.version,
    },
  };

  try {
    await respond({
      response,
      callbackUrl: message.callbackUrl,
      eventParams,
    });
  } catch (e) {
    diagnosticLog({
      name: 'encode_response_failure',
      params: {
        ...eventParams.params,
        error: (e as Error).message,
      },
    });

    throw e;
  }
}

export function shouldRespondToClient(
  responseMap: Map<number, ReturnValue>,
  message: RequestMessage,
): boolean {
  const actions = message.actions.filter((value) => !isHandshakeAction(value));
  return responseMap.size === actions.length;
}
