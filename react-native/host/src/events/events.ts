import { EmitterSubscription, EventEmitter } from 'react-native';

// Request Decoding
type RequestEventParams = {
  callbackUrl: string;
  sdkVersion: string;
};

type DecryptRequestStartEvent = {
  name: 'decrypt_request_start';
  params: RequestEventParams;
};

type DecryptRequestSuccessEvent = {
  name: 'decrypt_request_success';
  params: RequestEventParams;
};

type DecryptRequestFailureEvent = {
  name: 'decrypt_request_failure';
  params: RequestEventParams & { error: string };
};

// Sessions
type SessionNotFoundEvent = {
  name: 'session_not_found';
  params: {
    callbackUrl: string;
  };
};

type SessionExpiredEvent = {
  name: 'session_expired';
  params: {
    appName: string;
    appId: string;
    callbackUrl: string;
  };
};

type SessionAddedEvent = {
  name: 'session_added';
  params: {
    callbackUrl: string;
    appName: string;
    appId: string;
    sdkVersion: string;
  };
};

// Response Encoding
type ResponseEventParams = {
  callbackUrl: string;
  appName: string;
  appId: string;
  sdkVersion: string;
};

type EncodeResponseStartEvent = {
  name: 'encode_response_start';
  params: ResponseEventParams;
};

type EncodeResponseSuccessEvent = {
  name: 'encode_response_success';
  params: ResponseEventParams;
};

type EncodeResponseFailureEvent = {
  name: 'encode_response_failure';
  params: ResponseEventParams & { error: string };
};

// Respond to client
type SendSuccessResponseEvent = {
  name: 'send_success_response';
  params: {
    requestType: 'handshake' | 'request';
    callbackUrl: string;
    appName: string;
    appId: string;
  };
};

type SendFailureResponseEvent = {
  name: 'send_failure_response';
  params: {
    requestType: 'handshake' | 'request';
    error: string;
    callbackUrl: string;
    appName?: string;
    appId?: string;
  };
};

type MWPEvent =
  | DecryptRequestStartEvent
  | DecryptRequestSuccessEvent
  | DecryptRequestFailureEvent
  | SessionNotFoundEvent
  | SessionExpiredEvent
  | SessionAddedEvent
  | EncodeResponseStartEvent
  | EncodeResponseSuccessEvent
  | EncodeResponseFailureEvent
  | SendSuccessResponseEvent
  | SendFailureResponseEvent;

const diagnosticLogger = new EventEmitter();

export function addDiagnosticLogListener(listener: (event: MWPEvent) => void): EmitterSubscription {
  return diagnosticLogger.addListener('mwp_event', listener);
}

export function diagnosticLog(event: MWPEvent) {
  diagnosticLogger.emit('mwp_event', event);
}
