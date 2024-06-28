import { useCallback } from 'react';

import {
  deleteSessions as deleteMWPSessions,
  getSessions as getMWPSessions,
  type SecureStorage,
  type Session,
} from './sessions';

export function useSessions(storage: SecureStorage) {
  const getSessions = useCallback(
    async () => getMWPSessions(storage),
    [storage]
  );

  const deleteSessions = useCallback(
    async (sessions: Session[]) => deleteMWPSessions(storage, sessions),
    [storage]
  );

  return {
    getSessions,
    deleteSessions,
  };
}
