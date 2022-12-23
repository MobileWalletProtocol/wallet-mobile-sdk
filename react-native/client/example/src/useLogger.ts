import {useCallback, useState} from 'react';

export function useLogger() {
  const [output, setOutput] = useState('');

  const log = useCallback((message: string) => {
    setOutput(prev => `${message}\n${prev}`);
  }, []);

  return {output, log};
}
