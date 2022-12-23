import {MMKV} from 'react-native-mmkv';
import {Connection} from './ConnectWallet';

const store = new MMKV();

export function getActiveConnection(): Connection | null {
  let json = store.getString('active_connection');
  return json !== undefined ? (JSON.parse(json) as Connection) : null;
}

export function saveActiveConnection(connection: Connection | null) {
  if (connection === null) {
    store.delete('active_connection');
  } else {
    let json = JSON.stringify(connection);
    store.set('active_connection', json);
  }
}
