import {
  isEthereumAction,
  isHandshakeAction,
  RequestMessage,
} from '@coinbase/mobile-wallet-protocol-host';
import { StyleSheet, Text, View } from 'react-native';
import React, { useState } from 'react';
import { HandshakeActionItem } from './HandshakeActionItem';
import { RequestActionItem } from './RequestActionItem';

type ActionsScreenProps = {
  message: RequestMessage;
};

export function ActionsScreen({ message }: ActionsScreenProps) {
  const [activeIndex, setActiveIndex] = useState(0);

  const activeAction = message.actions[activeIndex];
  if (!activeAction) {
    return null;
  }

  if (isHandshakeAction(activeAction)) {
    return (
      <HandshakeActionItem action={activeAction} onHandled={() => setActiveIndex((i) => i + 1)} />
    );
  }

  if (isEthereumAction(activeAction)) {
    return (
      <RequestActionItem action={activeAction} onHandled={() => setActiveIndex((i) => i + 1)} />
    );
  }

  return (
    <View style={styles.unknownActionContainer}>
      <Text>Unknown Request Type</Text>
      <Text>{JSON.stringify(activeAction)}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
  },
  unknownActionContainer: {
    padding: 16,
  },
});
