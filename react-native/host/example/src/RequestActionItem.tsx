import {
  EthereumRequestAction,
  useMobileWalletProtocolHost,
} from '@coinbase/mobile-wallet-protocol-host';
import React from 'react';
import { Button, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

type RequestItemProps = {
  action: EthereumRequestAction;
  onHandled: () => void;
};

export function RequestActionItem({ action, onHandled }: RequestItemProps) {
  const insets = useSafeAreaInsets();

  const { approveAction, rejectAction } = useMobileWalletProtocolHost();

  const approve = async () => {
    await approveAction(action, { value: '0xdeadbeef' });
    onHandled();
  };

  const reject = async () => {
    await rejectAction(action, { code: 4001, message: 'User rejected request' });
    onHandled();
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <Text>Request</Text>
      <Text>{action.method}</Text>
      <Text>{JSON.stringify(action.params, null, 4)}</Text>
      <View style={styles.buttonContainer}>
        <Button title="Approve" onPress={approve} />
        <View style={styles.space} />
        <Button title="Reject" onPress={reject} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingHorizontal: 16,
  },
  buttonContainer: {
    flexDirection: 'row',
    paddingTop: 8,
  },
  space: {
    width: 8,
  },
});
