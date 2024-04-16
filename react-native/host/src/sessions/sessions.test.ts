import {
  addSessions,
  deleteSessions,
  getSessions,
  SecureStorage,
  Session,
  updateSessions,
} from './sessions';

const map = new Map<string, string>();
const inMemoryStore: SecureStorage = {
  get: async <T>(key: string) => {
    const dataJson = map.get(key);
    if (dataJson === undefined) {
      return undefined;
    }
    return Promise.resolve(JSON.parse(dataJson) as T);
  },
  set: async <T>(key: string, value: T) => {
    const encoded = JSON.stringify(value);
    map.set(key, encoded);
    return Promise.resolve();
  },
  remove: async (key: string) => {
    map.delete(key);
    return Promise.resolve();
  },
};

const mockSessions: Session[] = [
  {
    dappId: 'kalsjhdflakjshf',
    dappName: 'Dapp A',
    dappURL: 'https://www.dapp-a.com',
    generationTime: new Date().toString(),
    lastAccessTime: new Date().toString(),
    sessionId: 'askjdhfaksjdh',
    sessionPrivateKey: 'khjadsgjrfsd',
    sessionPublicKey: 'jkxhblfjkahsegrbfl',
    clientPublicKey: 'jiuaweykjhsfkdjfh',
  },
  {
    dappId: 'nqoweiubovcaijsdbhv',
    dappName: 'Dapp B',
    dappURL: 'https://www.dapp-b.com',
    generationTime: new Date().toString(),
    lastAccessTime: new Date().toString(),
    sessionId: 'ojk2wehbofwiue',
    sessionPrivateKey: 'amnasbdfkajlss',
    sessionPublicKey: 'iowuhelfkjasxdfh',
    clientPublicKey: 'zhxkjdhflaskudfh',
  },
  {
    dappId: 'iouqwyeurpiqu',
    dappName: 'Dapp C',
    dappURL: 'https://www.dapp-c.com',
    generationTime: new Date().toString(),
    lastAccessTime: new Date().toString(),
    sessionId: 'iushfp9qw8',
    sessionPrivateKey: 'iuhpiwoeuhfpi',
    sessionPublicKey: 'npaviwuehpaoieh',
    clientPublicKey: 'wjmebflkjsdhbaflk',
  },
];

async function setMockSessions() {
  await inMemoryStore.set('nativeSessions', mockSessions);
}

describe('sessions', () => {
  beforeEach(() => {
    map.clear();
  });

  it('should return empty array when there are no sessions in storage', async () => {
    const sessions = await getSessions(inMemoryStore);
    expect(sessions).toStrictEqual([]);
  });

  it('should return sessions when there are sessions in storage', async () => {
    await setMockSessions();

    const sessions = await getSessions(inMemoryStore);
    expect(sessions).toEqual(mockSessions);
  });

  it('should add sessions when addSessions is called', async () => {
    await setMockSessions();

    const newSession = {
      dappId: 'jahgsdkfjahgsjfg',
      dappName: 'Dapp D',
      dappURL: 'https://www.dapp-d.com',
      generationTime: new Date().toString(),
      lastAccessTime: new Date().toString(),
      sessionId: 'ihvjbnkasjd',
      sessionPrivateKey: 'nakjsdbcsw',
      sessionPublicKey: 'yutujqwehbf',
      clientPublicKey: 'spkjwehkjxcnb',
    };

    await addSessions(inMemoryStore, [newSession]);

    const sessions = await getSessions(inMemoryStore);
    expect(sessions).toContainEqual(newSession);
  });

  it('should update sessions when updateSessions is called', async () => {
    await setMockSessions();

    const sessionsToUpdate = [
      {
        dappId: 'kalsjhdflakjshf',
        dappName: 'UPDATED: Dapp A',
        dappURL: 'https://www.dapp-a.com',
        generationTime: new Date().toString(),
        lastAccessTime: new Date().toString(),
        sessionId: 'askjdhfaksjdh',
        sessionPrivateKey: 'khjadsgjrfsd',
        sessionPublicKey: 'jkxhblfjkahsegrbfl',
        clientPublicKey: 'jiuaweykjhsfkdjfh',
      },
      {
        dappId: 'nqoweiubovcaijsdbhv',
        dappName: 'UPDATED: Dapp B',
        dappURL: 'https://www.dapp-b.com',
        generationTime: new Date().toString(),
        lastAccessTime: new Date().toString(),
        sessionId: 'ojk2wehbofwiue',
        sessionPrivateKey: 'amnasbdfkajlss',
        sessionPublicKey: 'iowuhelfkjasxdfh',
        clientPublicKey: 'zhxkjdhflaskudfh',
      },
    ];

    await updateSessions(inMemoryStore, sessionsToUpdate);

    const sessions = await getSessions(inMemoryStore);
    sessionsToUpdate.forEach((updatedSession) => {
      expect(sessions).toContainEqual(updatedSession);
    });
  });

  it('should delete sessions when deleteSessions is called', async () => {
    await setMockSessions();

    const sessionsToDelete = [
      {
        dappId: 'kalsjhdflakjshf',
        dappName: 'Dapp A',
        dappURL: 'https://www.dapp-a.com',
        generationTime: new Date().toString(),
        lastAccessTime: new Date().toString(),
        sessionId: 'askjdhfaksjdh',
        sessionPrivateKey: 'khjadsgjrfsd',
        sessionPublicKey: 'jkxhblfjkahsegrbfl',
        clientPublicKey: 'jiuaweykjhsfkdjfh',
      },
      {
        dappId: 'nqoweiubovcaijsdbhv',
        dappName: 'Dapp B',
        dappURL: 'https://www.dapp-b.com',
        generationTime: new Date().toString(),
        lastAccessTime: new Date().toString(),
        sessionId: 'ojk2wehbofwiue',
        sessionPrivateKey: 'amnasbdfkajlss',
        sessionPublicKey: 'iowuhelfkjasxdfh',
        clientPublicKey: 'zhxkjdhflaskudfh',
      },
    ];

    await deleteSessions(inMemoryStore, sessionsToDelete);

    const sessions = await getSessions(inMemoryStore);
    expect(sessions).toHaveLength(1);
  });
});
