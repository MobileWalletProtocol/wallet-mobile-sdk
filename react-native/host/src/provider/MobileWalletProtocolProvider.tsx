import { createContext, ReactNode, useCallback, useMemo, useState } from 'react';

import { isHandshakeAction, RequestAction } from '../action/action';
import { DecodedRequest, decodeRequest, decryptRequest } from '../request/decoding';
import {
  mapDecryptedContentToRequest,
  mapHandshakeToRequest,
  RequestMessage,
} from '../request/request';
import {
  ErrorValue,
  ResultValue,
  ReturnValue,
  sendError,
  sendResponse,
  shouldRespondToClient,
} from '../response/response';
import { createSession } from '../sessions/createSession';
import {
  addSession,
  deleteSessions,
  getSession,
  getSessions,
  isSessionValid,
  SecureStorage,
  Session,
} from '../sessions/sessions';
import { AppMetadata, fetchClientAppMetadata } from '../utils/fetchClientAppMetadata';
import { isClientAppVerified } from '../utils/isClientAppVerified';
import React from 'react';
import { diagnosticLog } from '../events/events';

type MWPHostContextType = {
  message: RequestMessage | null;
  session: Session | null;
  handleRequestUrl: (url: string) => Promise<HandleRequestUrlResponse>;
  fetchClientAppMetadata: () => Promise<AppMetadata | null>;
  isClientAppVerified: () => Promise<boolean>;
  approveHandshake: (metadata: AppMetadata | null) => Promise<boolean>;
  rejectHandshake: (description: string) => Promise<boolean>;
  approveAction: (action: RequestAction, result: ResultValue) => Promise<boolean>;
  rejectAction: (action: RequestAction, error: ErrorValue) => Promise<boolean>;
  sendFailureToClient: (errorMessage: string, decodedRequest: DecodedRequest) => Promise<void>;
};

type MWPHostProviderProps = {
  secureStorage: SecureStorage;
  sessionExpiryDays: number;
  children?: ReactNode;
};

type HandleRequestUrlResponse = {
  success: boolean;
  error?: {
    type: 'session_not_found' | 'session_expired';
    errorMessage: string;
    decodedRequest: DecodedRequest;
  };
};

const actionToResponseMap = new Map<number, ReturnValue>();

export const MobileWalletProtocolContext = createContext<MWPHostContextType | null>(null);

export function MobileWalletProtocolProvider({
  children,
  secureStorage,
  sessionExpiryDays,
}: MWPHostProviderProps) {
  const [activeMessage, setActiveMessage] = useState<RequestMessage | null>(null);
  const [activeSession, setActiveSession] = useState<Session | null>(null);

  const updateActiveMessage = useCallback(
    (message: RequestMessage | null, session: Session | null) => {
      actionToResponseMap.clear();
      setActiveMessage(message);
      setActiveSession(session);
    },
    [],
  );

  const handleRequestUrl = useCallback(
    async (url: string): Promise<HandleRequestUrlResponse> => {
      const decoded = await decodeRequest(url);
      if (!decoded) {
        return { success: false };
      }

      if ('handshake' in decoded.content) {
        diagnosticLog({
          name: 'request_started',
          params: {
            requestType: 'handshake',
            callbackUrl: decoded.callbackUrl,
            sdkVersion: decoded.version,
          },
        });

        const message = mapHandshakeToRequest(decoded.content.handshake, decoded);
        updateActiveMessage(message, null);
        return { success: true };
      }

      if ('request' in decoded.content) {
        const session = await getSession(secureStorage, decoded);
        if (!session) {
          diagnosticLog({
            name: 'session_not_found',
            params: { callbackUrl: decoded.callbackUrl },
          });

          return {
            success: false,
            error: {
              type: 'session_not_found',
              errorMessage:
                'Session not found. Please initiate a handshake request prior to making a request',
              decodedRequest: decoded,
            },
          };
        }

        if (!isSessionValid(session, sessionExpiryDays)) {
          diagnosticLog({
            name: 'session_expired',
            params: {
              appName: session.dappName,
              appId: session.dappId,
              callbackUrl: session.dappURL,
            },
          });

          await deleteSessions(secureStorage, [session]);

          return {
            success: false,
            error: {
              type: 'session_expired',
              errorMessage:
                'Session expired. Please initiate another handshake request to connect.',
              decodedRequest: decoded,
            },
          };
        }

        diagnosticLog({
          name: 'request_started',
          params: {
            requestType: 'request',
            callbackUrl: decoded.callbackUrl,
            sdkVersion: decoded.version,
            appId: session.dappId,
            appName: session.dappName,
          },
        });

        const decrypted = await decryptRequest(url, session);
        const message = mapDecryptedContentToRequest(decrypted.content.request, decoded);
        updateActiveMessage(message, session);
        return { success: true };
      }

      return { success: false };
    },
    [secureStorage, sessionExpiryDays, updateActiveMessage],
  );

  const fetchAppMetadata = useCallback(async () => {
    const handshake = activeMessage?.actions.find(isHandshakeAction);
    if (!handshake) {
      throw new Error('No handshake action');
    }

    return fetchClientAppMetadata({
      appId: handshake.appId,
      appUrl: handshake.callback,
    });
  }, [activeMessage?.actions]);

  const isAppVerified = useCallback(async () => {
    const handshake = activeMessage?.actions.find(isHandshakeAction);
    if (!handshake) {
      throw new Error('No handshake action');
    }

    return isClientAppVerified({
      appId: handshake.appId,
      callbackUrl: handshake.callback,
    });
  }, [activeMessage?.actions]);

  const approveHandshake = useCallback(
    async (metadata: AppMetadata | null): Promise<boolean> => {
      if (!activeMessage) {
        throw new Error('No message found');
      }

      const action = activeMessage.actions.find(isHandshakeAction);
      if (!action) {
        throw new Error('No handshake action');
      }

      const appMetadata = metadata ?? {
        appId: action.appId,
        appUrl: action.callback,
      };

      const session = await createSession(appMetadata, action, activeMessage);
      const sessions = await getSessions(secureStorage);

      // Delete existing session if it matches the app id
      const existingSession = sessions.find((value) => value.dappId === appMetadata.appId);
      if (existingSession) {
        await deleteSessions(secureStorage, [existingSession]);
      }

      await addSession(secureStorage, session);

      if (shouldRespondToClient(actionToResponseMap, activeMessage)) {
        await sendResponse(actionToResponseMap, activeMessage, secureStorage);
        updateActiveMessage(null, null);
        return false;
      }

      return true;
    },
    [activeMessage, secureStorage, updateActiveMessage],
  );

  const rejectHandshake = useCallback(
    async (description: string): Promise<boolean> => {
      if (!activeMessage) {
        throw new Error('No message found');
      }

      await sendError(description, activeMessage);
      updateActiveMessage(null, null);
      return false;
    },
    [activeMessage, updateActiveMessage],
  );

  const approveAction = useCallback(
    async (action: RequestAction, result: ResultValue): Promise<boolean> => {
      if (!activeMessage) {
        throw new Error('No message found');
      }

      actionToResponseMap.set(action.id, { result });

      if (shouldRespondToClient(actionToResponseMap, activeMessage)) {
        await sendResponse(actionToResponseMap, activeMessage, secureStorage);
        updateActiveMessage(null, null);
        return false;
      }

      return true;
    },
    [activeMessage, secureStorage, updateActiveMessage],
  );

  const rejectAction = useCallback(
    async (action: RequestAction, error: ErrorValue): Promise<boolean> => {
      if (!activeMessage) {
        throw new Error('No message found');
      }

      actionToResponseMap.set(action.id, { error });

      if (action.optional) {
        if (shouldRespondToClient(actionToResponseMap, activeMessage)) {
          await sendResponse(actionToResponseMap, activeMessage, secureStorage);
          updateActiveMessage(null, null);
          return false;
        }
      } else {
        await sendResponse(actionToResponseMap, activeMessage, secureStorage);
        updateActiveMessage(null, null);
        return false;
      }

      return true;
    },
    [activeMessage, secureStorage, updateActiveMessage],
  );

  const value = useMemo(() => {
    return {
      message: activeMessage,
      session: activeSession,
      handleRequestUrl,
      approveHandshake,
      rejectHandshake,
      approveAction,
      rejectAction,
      fetchClientAppMetadata: fetchAppMetadata,
      isClientAppVerified: isAppVerified,
      sendFailureToClient: sendError,
    };
  }, [
    activeMessage,
    activeSession,
    approveAction,
    approveHandshake,
    fetchAppMetadata,
    handleRequestUrl,
    isAppVerified,
    rejectAction,
    rejectHandshake,
  ]);

  return (
    <MobileWalletProtocolContext.Provider value={value}>
      {children}
    </MobileWalletProtocolContext.Provider>
  );
}
