import { emitEvent } from '../events/events';

const SESSIONS_KEY = 'nativeSessions';

export type Session = {
  dappId: string;
  dappName: string;
  dappURL: string;
  dappImageURL?: string;
  dappBase64Image?: string;
  generationTime: string;
  lastAccessTime: string;
  sessionId: string;
  sessionPrivateKey: string;
  sessionPublicKey: string;
  clientPublicKey: string;
  version?: string;
};

export type SecureStorage = {
  get: <T>(key: string) => Promise<T | undefined>;
  set: <T>(key: string, value: T) => Promise<void>;
  remove: (key: string) => Promise<void>;
};

function findMatchingSession(sessions: Session[], sessionToFind: Session) {
  return sessions.find((session) => session.sessionPublicKey === sessionToFind.sessionPublicKey);
}

export function isSessionValid(session: Session, expiryDeltaDays: number): boolean {
  const lastAccessTime = new Date(session.lastAccessTime);
  const now = new Date();

  const delta = now.getTime() - lastAccessTime.getTime();
  if (delta < 0) {
    // Last access time was in the future
    return false;
  }

  const deltaDays = delta / (1000 * 3600 * 24); // ms to days
  return deltaDays <= expiryDeltaDays;
}

export async function getSessions(storage: SecureStorage): Promise<Session[]> {
  const sessions = await storage.get<Session[]>(SESSIONS_KEY);
  return sessions ?? [];
}

export async function addSessions(storage: SecureStorage, sessions: Session[]) {
  const existingSessions = await getSessions(storage);
  await storage.set<Session[]>(SESSIONS_KEY, existingSessions.concat(sessions));
}

export async function updateSessions(storage: SecureStorage, sessions: Session[]) {
  const existingSessions = await getSessions(storage);
  const updatedSessions = existingSessions.map((existingSession) => {
    const matchingSession = findMatchingSession(sessions, existingSession);
    return matchingSession ?? existingSession;
  });
  await storage.set<Session[]>(SESSIONS_KEY, updatedSessions);
}

export async function deleteSessions(storage: SecureStorage, sessions: Session[]) {
  const existingSessions = await getSessions(storage);
  const updatedSessions = existingSessions.filter((session) => {
    const matchingSession = findMatchingSession(sessions, session);
    return matchingSession === undefined;
  });
  await storage.set<Session[]>(SESSIONS_KEY, updatedSessions);
}

export async function getSession(
  storage: SecureStorage,
  message: { sender: string },
): Promise<Session | undefined> {
  const sessions = await getSessions(storage);
  return sessions.find((value) => value.clientPublicKey === message.sender);
}

export async function addSession(storage: SecureStorage, session: Session) {
  await addSessions(storage, [session]);

  emitEvent({
    name: 'session_added',
    params: {
      callbackUrl: session.dappURL,
      appId: session.dappId,
      appName: session.dappName,
      sdkVersion: session.version ?? '0',
    },
  });
}
