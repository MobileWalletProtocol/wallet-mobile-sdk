import React from 'react';
import {useState, useEffect} from 'react';
import {Linking, SafeAreaView, StatusBar, StyleSheet} from 'react-native';

import {MWPClient} from '@coinbase/wallet-mobile-sdk';
import {Connection, ConnectWallet} from './ConnectWallet';
import {getActiveConnection, saveActiveConnection} from './connectionStorage';
import {Home} from './Home';

// Configure MWPClient
MWPClient.configure({
  callbackURL: 'example.rn.dapp://', // Your app's Universal Link
});

function App() {
  const [connection, setActiveConnection] = useState<Connection | null>(() => {
    return getActiveConnection();
  });

  useEffect(function setupDeeplinkHandling() {
    // Pass incoming deeplinks into Mobile SDK
    const subscription = Linking.addEventListener('url', ({url}) => {
      console.log('-- handleResponse --', url);
      MWPClient.handleResponse(new URL(url));
    });

    return function cleanup() {
      subscription.remove();
    };
  }, []);

  const onConnect = (newConnection: Connection) => {
    setActiveConnection(newConnection);
    saveActiveConnection(newConnection);
  };

  const onSignOut = () => {
    setActiveConnection(null);
    saveActiveConnection(null);
  };

  return (
    <SafeAreaView style={styles.background}>
      <StatusBar />
      {connection === null ? (
        <ConnectWallet onConnect={onConnect} />
      ) : (
        <Home connection={connection} onSignOut={onSignOut} />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  background: {
    flex: 1,
  },
});

export default App;
