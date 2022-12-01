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
  connectWallet,
  getEvmProvider,
  getWallets,
  handleResponse,
} from '@coinbase/wallet-mobile-sdk';
import {MMKV} from 'react-native-mmkv';

// Configure Mobile SDK
configure({
  callbackURL: new URL('example.rn.dapp://'), // Your app's Universal Link
});

const App = function () {
  const [log, setLog] = useState('');

  const [activeWallet, setActiveWallet] = useState(undefined);
  const [providerMap, setProviderMap] = useState(new Map());
  const cachedAddress = useMemo(
    () =>
      activeWallet
        ? providerMap.get(activeWallet.url)._storage.getString('address')
        : undefined,
    [activeWallet, providerMap],
  );
  const [address, setAddress] = useState(cachedAddress);
  const [wallets, setWallets] = useState([]);
  const isConnected = address !== undefined;

  const add = (key, value) => {
    setProviderMap(prev => new Map([...prev, [key, value]]));
  };

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

  useEffect(() => {
    setWallets(getWallets());
  }, []);

  useEffect(() => {
    if (activeWallet && providerMap.has(activeWallet.url)) {
      setAddress(
        providerMap.get(activeWallet.url)._storage.getString('address'),
      );
    }
  }, [providerMap, activeWallet]);

  // Initiate connection to Wallet
  const connectWallet2 = useCallback(async () => {
    logMessage('--> eth_requestAccounts\n');

    try {
      const provider = providerMap.get(activeWallet.url);
      const accounts = await provider.request({
        method: 'eth_requestAccounts',
        params: [],
      });
      setAddress(accounts[0]);
      provider._storage.set('address', accounts[0]);

      logMessage(`<-- ${accounts}`);
    } catch (e) {
      console.error(e.message);
      logMessage('<-- error connecting');
    }
  }, [activeWallet, logMessage, providerMap]);

  // Reset connection to Wallet
  const resetConnection = useCallback(() => {
    logMessage('--- Disconnect\n');
    const provider = providerMap.get(activeWallet.url);
    provider.disconnect();
    setAddress(undefined);
    provider._storage.delete('address');
  }, [activeWallet, logMessage, providerMap]);

  const personalSign = useCallback(async () => {
    logMessage('--> personal_sign\n');

    try {
      const provider = providerMap.get(activeWallet.url);
      const result = await provider.request({
        method: 'personal_sign',
        params: ['0x48656c6c6f20776f726c64', address],
      });

      logMessage(`<-- ${result}`);
    } catch (e) {
      logMessage(`<-- ${e.message}`);
    }
  }, [logMessage, providerMap, activeWallet, address]);

  const switchToEthereumChain = useCallback(async () => {
    logMessage('--> wallet_switchEthereumChain: 0x1\n');

    try {
      const provider = providerMap.get(activeWallet.url);
      const result = await provider.request({
        method: 'wallet_switchEthereumChain',
        params: [{chainId: '0x1'}],
      });

      logMessage(`<-- ${result}`);
    } catch (e) {
      console.error(e.message);
      logMessage('<-- error');
    }
  }, [activeWallet, logMessage, providerMap]);

  const switchToPolygonChain = useCallback(async () => {
    logMessage('--> wallet_switchEthereumChain: 0x89\n');

    try {
      const provider = providerMap.get(activeWallet.url);
      const result = await provider.request({
        method: 'wallet_switchEthereumChain',
        params: [{chainId: '0x89'}],
      });

      logMessage(`<-- ${result}`);
    } catch (e) {
      console.error(e.message);
      logMessage('<-- error');
    }
  }, [activeWallet, logMessage, providerMap]);

  const addMumbaiTestnet = useCallback(async () => {
    logMessage('--> wallet_addEthereumChain: Mumbai Testnet\n');

    try {
      const provider = providerMap.get(activeWallet.url);
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
  }, [activeWallet, logMessage, providerMap]);

  const backgroundStyle = {
    backgroundColor: Colors.lighter,
  };

  const selectWallet = useCallback(
    wallet => {
      setActiveWallet(wallet);
      try {
        if (!providerMap.has(wallet.url)) {
          const localStorage = new MMKV({
            id: `${wallet.name}.mobile_sdk.store`,
          });
          const options = {storage: localStorage};
          add(wallet.url, getEvmProvider(wallet, options));
        }
        connectWallet(wallet);
      } catch (e) {
        console.error(e.message);
      }
    },
    [providerMap, setActiveWallet],
  );

  const disconnectWallet = useCallback(() => {
    setActiveWallet(undefined);
    setAddress(undefined);
  }, [setActiveWallet]);

  return activeWallet ? (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar />
      <ScrollView style={styles.scrollViewStyle}>
        <Section title="Methods">
          {!isConnected ? (
            <Button title="Connect Wallet" onPress={connectWallet2} />
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

// noinspection JSUnresolvedFunction
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

// noinspection JSUnresolvedFunction
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
