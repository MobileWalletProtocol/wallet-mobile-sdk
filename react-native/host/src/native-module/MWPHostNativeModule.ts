import { NativeModules, Platform } from 'react-native';

type GenerateKeyPairResult = {
  publicKey: string;
  privateKey: string;
};

type Action = { method: string; paramsJson: string; optional: boolean };

type RequestContent =
  | {
      handshake: {
        appId: string;
        callback: string;
        initialActions?: Action[];
      };
    }
  | {
      request: {
        account: {
          chain: string;
          networkId: number;
          address: string;
        };
        actions: Action[];
      };
    };

type DecodeRequestResult = {
  version: string;
  sender: string;
  content: RequestContent;
  uuid: string;
  callbackUrl: string;
};

type GetClientAppMetadataResult = {
  appName: string;
  appIconBase64: string;
  certificateMatch: boolean;
};

type GetClientAppMetadataV2Result = {
  appName: string;
  appIconBase64: string;
};

// TODO: Change UnencodedResponseContent to union type
// type UnencodedResponseContent =
//   | {
//       response: {
//         requestId: string;
//         values: {
//           result?: { value: string };
//           error?: { code: number; message: string };
//         }[];
//       };
//     }
//   | {
//       failure: {
//         requestId: string;
//         description: string;
//       };
//     };

type UnencodedResponseContent = {
  response?: {
    requestId: string;
    values: {
      result?: { value: string };
      error?: { code: number; message: string };
    }[];
  };
  failure?: {
    requestId: string;
    description: string;
  };
};

type UnencodedResponse = {
  version: string;
  sender: string;
  content: UnencodedResponseContent;
  timestamp: number;
  uuid: string;
  callbackUrl: string;
};

type MWPHostNativeModule = {
  getSdkVersion: () => Promise<string>;

  generateKeyPair: () => Promise<GenerateKeyPairResult>;

  decodeRequest: (
    url: string,
    sessionPrivateKey: string,
    clientPublicKey: string,
  ) => Promise<DecodeRequestResult>;

  encodeResponse: (
    unencodedResponse: UnencodedResponse | string,
    clientUrl: string,
    sessionPrivateKey: string,
    clientPublicKey: string,
  ) => Promise<string>;

  getClientAppMetadata: (wellKnownCertificates: string[]) => Promise<GetClientAppMetadataResult>;

  getClientAppMetadataV2: () => Promise<GetClientAppMetadataV2Result>;

  getClientAppSignatures: () => Promise<string[]>;

  triggerWalletSDKCallback: (domain: string) => Promise<void>;

  getIntentUrl: () => Promise<string | null>;
};

export const MWPHostModule = NativeModules.MobileWalletProtocolHost as MWPHostNativeModule;

export function getAndroidIntentUrl(): Promise<string | null> {
  if (Platform.OS === 'android') {
    return MWPHostModule.getIntentUrl();
  } else {
    return Promise.resolve(null);
  }
}
