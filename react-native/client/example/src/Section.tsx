import React from 'react';
import {StyleSheet, Text, View} from 'react-native';

type SectionProps = {
  children: React.ReactNode;
  title: string;
};

export function Section({children, title}: SectionProps) {
  return (
    <View style={[styles.sectionContainer]}>
      <Text style={[styles.sectionTitle]}>{title}</Text>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  sectionContainer: {
    padding: 16,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
  },
});
