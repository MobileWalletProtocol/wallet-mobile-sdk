import React from 'react';
import {useState, useMemo, useEffect, useCallback} from 'react';
import {
  Button,
  Image,
  Linking,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  View,
} from 'react-native';

import {Colors} from 'react-native/Libraries/NewAppScreen';

import {
  configure,
  handleResponse,
  WalletMobileSDKEVMProvider,
} from '@coinbase/wallet-mobile-sdk';
import {MMKV} from 'react-native-mmkv';

// Configure Mobile SDK
configure({
  callbackURL: new URL('example.rn.dapp://'), // Your app's Universal Link
});

const provider = new WalletMobileSDKEVMProvider();
const storage = new MMKV();

const App = function () {
  const [log, setLog] = useState('');

  const cachedAddress = useMemo(() => storage.getString('address'), []);
  const [address, setAddress] = useState(cachedAddress);
  const [activeWallet, setActiveWallet] = useState(undefined);
  const [wallets, setWallets] = useState([]);

  const isConnected = address !== undefined;

  useEffect(function setupDeeplinkHandling() {
    // Pass incoming deeplinks into Mobile SDK
    const subscription = Linking.addEventListener('url', ({url}) => {
      console.log('-- handleResponse --', url);
      handleResponse(url);
    });

    return function cleanup() {
      subscription.remove();
    };
  }, []);

  const logMessage = useCallback(message => {
    setLog(prev => `${message}\n${prev}`);
  }, []);

  useEffect(function getWallets() {
    setWallets(provider.getWallets);
  }, []);

  // Initiate connection to Wallet
  const connectWallet = useCallback(async () => {
    logMessage('--> eth_requestAccounts\n');

    try {
      const accounts = await provider.request({
        method: 'eth_requestAccounts',
        params: [],
      });
      setAddress(accounts[0]);
      storage.set('address', accounts[0]);

      logMessage(`<-- ${accounts}`);
    } catch (e) {
      console.error(e.message);
      logMessage('<-- error connecting');
    }
  }, [logMessage]);

  // Reset connection to Wallet
  const resetConnection = useCallback(() => {
    logMessage('--- Disconnect\n');

    provider.disconnect();
    setAddress(undefined);
    storage.delete('address');
  }, [logMessage]);

  const personalSign = useCallback(async () => {
    logMessage('--> personal_sign\n');

    try {
      const result = await provider.request({
        method: 'personal_sign',
        params: ['0x48656c6c6f20776f726c64', address],
      });

      logMessage(`<-- ${result}`);
    } catch (e) {
      logMessage(`<-- ${e.message}`);
    }
  }, [logMessage, address]);

  const switchToEthereumChain = useCallback(async () => {
    logMessage('--> wallet_switchEthereumChain: 0x1\n');

    try {
      const result = await provider.request({
        method: 'wallet_switchEthereumChain',
        params: [{chainId: '0x1'}],
      });

      logMessage(`<-- ${result}`);
    } catch (e) {
      console.error(e.message);
      logMessage('<-- error');
    }
  }, [logMessage]);

  const switchToPolygonChain = useCallback(async () => {
    logMessage('--> wallet_switchEthereumChain: 0x89\n');

    try {
      const result = await provider.request({
        method: 'wallet_switchEthereumChain',
        params: [{chainId: '0x89'}],
      });

      logMessage(`<-- ${result}`);
    } catch (e) {
      console.error(e.message);
      logMessage('<-- error');
    }
  }, [logMessage]);

  const addMumbaiTestnet = useCallback(async () => {
    logMessage('--> wallet_addEthereumChain: Mumbai Testnet\n');

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

      logMessage(`<-- ${result}`);
    } catch (e) {
      console.error(e.message);
      logMessage('<-- error');
    }
  }, [logMessage]);

  const backgroundStyle = {
    backgroundColor: Colors.lighter,
  };

  const selectWallet = useCallback(
    wallet => {
      setActiveWallet(wallet);
      try {
        console.log(wallet);
        provider.connectWallet(wallet);
      } catch (e) {
        console.error(e.message);
      }
    },
    [setActiveWallet],
  );

  const disconnectWallet = useCallback(() => {
    setActiveWallet(undefined);
  }, [setActiveWallet]);

  return activeWallet ? (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar />
      <ScrollView style={styles.scrollViewStyle}>
        <Section title="Methods">
          {!isConnected ? (
            <Button title="Connect Wallet" onPress={connectWallet} />
          ) : (
            <>
              <Button title="Reset Connection" onPress={resetConnection} />
              <Button title="Personal Sign" onPress={personalSign} />
              <Button
                title="Switch Chain: Ethereum"
                onPress={switchToEthereumChain}
              />
              <Button
                title="Switch Chain: Polygon"
                onPress={switchToPolygonChain}
              />
              <Button
                title="Add Chain: Mumbai Testnet"
                onPress={addMumbaiTestnet}
              />
            </>
          )}
          <Button title="Close Wallet Connection" onPress={disconnectWallet} />
        </Section>
      </ScrollView>
      <ScrollView style={styles.scrollViewStyle}>
        <Section title="Output">
          <Text style={{color: Colors.black}}>{log}</Text>
        </Section>
      </ScrollView>
    </SafeAreaView>
  ) : (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar />
      <Section title="Choose Wallet">
        {wallets.map(wallet => {
          return (
            <View
              style={walletStyles.view}
              onTouchStart={() => {
                selectWallet(wallet);
              }}>
              <Image style={walletStyles.logo} source={{uri: wallet.iconUrl}} />
              <Text style={walletStyles.item}>{wallet.name}</Text>
            </View>
          );
        })}
      </Section>
    </SafeAreaView>
  );
};

const Section = function ({children, title}) {
  return (
    <View style={[styles.sectionContainer]}>
      <Text
        style={[
          styles.sectionTitle,
          {
            color: Colors.black,
          },
        ]}>
        {title}
      </Text>
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 24,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
  scrollViewStyle: {
    height: '50%',
  },
});

const walletStyles = StyleSheet.create({
  container: {
    height: '100%',
    padding: 50,
  },
  view: {
    flexDirection: 'row',
    height: 100,
    padding: 10,
  },
  item: {
    padding: 20,
    fontSize: 15,
    marginTop: 0,
    color: Colors.black,
  },
  logo: {
    width: 66,
    height: 58,
  },
});

export default App;
