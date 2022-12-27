import {MWPEVMProvider} from '@coinbase/wallet-mobile-sdk';
import React, {useCallback, useMemo} from 'react';
import {ScrollView, StyleSheet, Text, View, Image, Button} from 'react-native';
import {MMKV} from 'react-native-mmkv';
import {Connection} from './ConnectWallet';
import {Section} from './Section';
import {useLogger} from './useLogger';

type HomeProps = {
  connection: Connection;
  onSignOut: () => void;
};

export function Home({connection, onSignOut}: HomeProps) {
  const provider = useMemo(() => {
    return new MWPEVMProvider({
      wallet: connection.wallet,
      address: connection.account.address,
      storage: new MMKV({id: 'mwp_provider.store'}),
    });
  }, []);

  const {output, log} = useLogger();

  const resetConnection = useCallback(() => {
    log('--- Disconnect\n');

    provider.disconnect();
    onSignOut();
  }, []);

  const personalSign = useCallback(async () => {
    log('--> personal_sign\n');

    try {
      const result = await provider.request({
        method: 'personal_sign',
        params: ['0x48656c6c6f20776f726c64', connection.account.address],
      });

      log(`<-- ${result}`);
    } catch (e) {
      console.error('error:', e);
      log(`<-- error`);
    }
  }, [log, connection.account.address]);

  const switchToEthereumChain = useCallback(async () => {
    log('--> wallet_switchEthereumChain: 0x1\n');

    try {
      const result = await provider.request({
        method: 'wallet_switchEthereumChain',
        params: [{chainId: '0x1'}],
      });

      log(`<-- ${result}`);
    } catch (e) {
      console.error('error:', e);
      log('<-- error');
    }
  }, [log]);

  const switchToPolygonChain = useCallback(async () => {
    log('--> wallet_switchEthereumChain: 0x89\n');

    try {
      const result = await provider.request({
        method: 'wallet_switchEthereumChain',
        params: [{chainId: '0x89'}],
      });

      log(`<-- ${result}`);
    } catch (e) {
      console.error('error:', e);
      log('<-- error');
    }
  }, [log]);

  const addMumbaiTestnet = useCallback(async () => {
    log('--> wallet_addEthereumChain: Mumbai Testnet\n');

    try {
      const result = await provider.request({
        method: 'wallet_addEthereumChain',
        params: [
          {
            chainId: '0x13881',
            chainName: 'Matic(Polygon) Mumbai Testnet',
            nativeCurrency: {
              name: 'tMATIC',
              symbol: 'tMATIC',
              decimals: 18,
            },
            rpcUrls: ['https://rpc-mumbai.maticvigil.com'],
            blockExplorerUrls: ['https://mumbai.polygonscan.com/'],
          },
        ],
      });

      log(`<-- ${result}`);
    } catch (e) {
      console.error('error:', e);
      log('<-- error');
    }
  }, [log]);

  return (
    <View style={styles.screen}>
      <View style={styles.methodsSection}>
        <Section title="Connection">
          <View style={styles.walletInfo}>
            <Image
              style={styles.logo}
              source={{uri: connection.wallet.iconUrl}}
            />
            <Text>{connection.wallet.name}</Text>
          </View>
          <Text style={styles.address}>{connection.account.address}</Text>
          <Button title="Sign Out" onPress={resetConnection} />
        </Section>
        <Section title="Methods">
          <ScrollView>
            <Spacer />
            <Button title="Personal Sign" onPress={personalSign} />
            <Spacer />
            <Button
              title="Switch Chain: Ethereum"
              onPress={switchToEthereumChain}
            />
            <Spacer />
            <Button
              title="Switch Chain: Polygon"
              onPress={switchToPolygonChain}
            />
            <Spacer />
            <Button
              title="Add Chain: Mumbai Testnet"
              onPress={addMumbaiTestnet}
            />
            <Spacer />
          </ScrollView>
        </Section>
      </View>
      <View style={styles.consoleSection}>
        <Section title="Console">
          <ScrollView>
            <Text>{output}</Text>
          </ScrollView>
        </Section>
      </View>
    </View>
  );
}

function Spacer() {
  return <View style={styles.spacer} />;
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    flexDirection: 'column',
    width: '100%',
  },
  methodsSection: {
    height: '60%',
  },
  consoleSection: {
    height: '40%',
  },
  walletInfo: {
    paddingTop: 8,
    paddingBottom: 8,
    flexDirection: 'row',
    alignItems: 'center',
  },
  logo: {
    width: 24,
    height: 24,
    borderRadius: 4,
    marginEnd: 8,
  },
  address: {
    paddingBottom: 8,
  },
  button: {
    marginTop: 8,
  },
  spacer: {
    height: 8,
  },
});
