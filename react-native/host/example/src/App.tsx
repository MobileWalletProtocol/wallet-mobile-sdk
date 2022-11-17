import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
// import {  } from '@coinbase/mobile-wallet-protocol-host';

// TODO: Implement example host wallet
export default function App() {
  const [result] = React.useState<number | undefined>();

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
