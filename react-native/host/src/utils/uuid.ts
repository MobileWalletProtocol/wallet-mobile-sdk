import UUID from 'react-native-uuid';

export function uuidV4(): string {
  const uuid = UUID.v4();
  if (typeof uuid === 'string') {
    return uuid;
  }
  return UUID.unparse(uuid);
}
