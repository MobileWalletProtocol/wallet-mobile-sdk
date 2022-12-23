import React, {useCallback} from 'react';
import {Image, StyleSheet, Text, TouchableOpacity, View} from 'react-native';
import {
  Account,
  getWallets,
  isWalletInstalled,
  MWPClient,
  Wallet,
} from '@coinbase/wallet-mobile-sdk';
import {Section} from './Section';

export type Connection = {
  wallet: Wallet;
  account: Account;
};

type ConnectWalletProps = {
  onConnect: (connection: Connection) => void;
};

export function ConnectWallet({onConnect}: ConnectWalletProps) {
  const installedWallets = getWallets().filter(isWalletInstalled);

  const onPress = useCallback(async (wallet: Wallet) => {
    try {
      let client = MWPClient.getInstance(wallet);
      const [_, account] = await client.initiateHandshake([
        {
          method: 'eth_requestAccounts',
          params: {},
          optional: false,
        },
      ]);

      if (account) {
        onConnect({wallet, account});
      } else {
        console.error('No account returned for handshake request');
      }
    } catch (e) {
      console.error('error:', e);
    }
  }, []);

  return (
    <Section title="Choose Wallet">
      {installedWallets.map(wallet => {
        return (
          <TouchableOpacity key={wallet.url} onPress={() => onPress(wallet)}>
            <View style={styles.container}>
              <Image style={styles.logo} source={{uri: wallet.iconUrl}} />
              <Text style={styles.item}>{wallet.name}</Text>
            </View>
          </TouchableOpacity>
        );
      })}
    </Section>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 16,
  },
  item: {
    paddingHorizontal: 16,
    fontSize: 20,
    fontWeight: 'bold',
  },
  logo: {
    width: 58,
    height: 58,
    borderRadius: 16,
  },
});
