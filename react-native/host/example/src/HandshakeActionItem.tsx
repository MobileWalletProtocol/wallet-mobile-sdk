import {
  HandshakeAction,
  useMobileWalletProtocolHost,
  AppMetadata,
} from '@coinbase/mobile-wallet-protocol-host';
import React, { useEffect, useState } from 'react';
import { Button, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

type HandshakeItemProps = {
  action: HandshakeAction;
  onHandled: (shouldContinue: boolean) => void;
};

export function HandshakeActionItem({ action, onHandled }: HandshakeItemProps) {
  const insets = useSafeAreaInsets();

  const [metadata, setMetadata] = useState<AppMetadata | null>(null);
  const [isVerified, setVerified] = useState<boolean | null>(null);

  const { fetchClientAppMetadata, isClientAppVerified, approveHandshake, rejectHandshake } =
    useMobileWalletProtocolHost();

  useEffect(() => {
    try {
      fetchClientAppMetadata().then((value) => setMetadata(value));
      isClientAppVerified().then((value) => setVerified(value));
    } catch (e) {
      console.error(e);
    }
  }, [fetchClientAppMetadata, isClientAppVerified]);

  const approve = async () => {
    const proceed = await approveHandshake(metadata);
    onHandled(proceed);
  };

  const reject = async () => {
    const proceed = await rejectHandshake('User rejected handshake');
    onHandled(proceed);
  };

  return (
    <View style={[styles.container, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
      <Text>Handshake</Text>
      <Text>App Id: {action.appId}</Text>
      <Text>Callback: {action.callback}</Text>
      <Text>Name: {metadata?.appName ?? 'Loading...'}</Text>
      <Text>Verified?: {isVerified === null ? 'Loading...' : `${isVerified}`}</Text>
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
