import { Platform } from 'react-native';

import { MWPHostModule } from '../native-module/MWPHostNativeModule';

import { isClientAppVerified } from './isClientAppVerified';

function mockFetch(response: any) {
  jest.spyOn(global, 'fetch').mockImplementation(async () => {
    const res = {
      json: async () => {
        return Promise.resolve(response);
      },
    } as Response;

    return Promise.resolve(res);
  });
}

function mockIosAppSiteAssociationV1() {
  mockFetch({
    applinks: {
      apps: [],
      details: [
        {
          appIDs: [
            'ABCD123XYZ.xyz.example.app',
            'ABCD123XYZ.xyz.example.app.beta',
          ],
          components: [],
        },
      ],
    },
  });
}

function mockIosAppSiteAssociationV2() {
  mockFetch({
    applinks: {
      apps: [],
      details: [
        {
          appID: 'ABCD123XYZ.xyz.example.app',
          paths: ['/wsegue'],
        },
      ],
    },
  });
}

function mockAndroidAssetlinksJson() {
  mockFetch([
    {
      relation: ['delegate_permission/common.handle_all_urls'],
      target: {
        namespace: 'android_app',
        package_name: 'xyz.example.app',
        sha256_cert_fingerprints: [
          '10:03:96:C0:E4:00:06:1B:10:5D:D9:60:1A:2E:61:04:E6:9D:C7:B4:D8:E9:95:FF:0A:A2:65:A6:8C:5F:D6:19',
          '61:0F:0D:1D:F6:EA:8C:C3:3C:90:33:8B:63:C4:67:A2:B2:D5:FF:C5:33:96:8D:C2:0D:B0:7D:2D:9E:49:F4:A9',
          'FC:97:DC:89:0A:48:C8:A1:7F:A1:C4:EC:8E:BD:19:58:72:68:C5:59:DD:05:63:B9:F4:9E:95:47:0F:AA:20:DF',
        ],
      },
    },
  ]);
}

jest.mock('../native-module/MWPHostNativeModule', () => ({
  MWPHostModule: {
    getClientAppSignatures: async () => Promise.resolve([]),
  },
}));

function mockAndroidClientSignatures(signatures: string[]) {
  MWPHostModule.getClientAppSignatures = async () =>
    Promise.resolve(signatures);
}

describe('isClientAppVerified', () => {
  it('should return false for non https url callback', async () => {
    const isVerified = await isClientAppVerified({
      appId: 'xyz.example.app',
      callbackUrl: 'http://example.xyz',
    });
    expect(isVerified).toBe(false);
  });

  it('should return false for custom scheme callback', async () => {
    const isVerified = await isClientAppVerified({
      appId: 'xyz.example.app',
      callbackUrl: 'example://wsegue',
    });
    expect(isVerified).toBe(false);
  });

  it('should return true for valid iOS apple-app-site-association', async () => {
    Platform.OS = 'ios';
    mockIosAppSiteAssociationV1();

    const isVerified = await isClientAppVerified({
      appId: 'xyz.example.app.beta',
      callbackUrl: 'https://example.xyz',
    });
    expect(isVerified).toBe(true);
  });

  it('should return true for valid iOS apple-app-site-association V2', async () => {
    Platform.OS = 'ios';
    mockIosAppSiteAssociationV2();

    const isVerified = await isClientAppVerified({
      appId: 'xyz.example.app',
      callbackUrl: 'https://example.xyz',
    });
    expect(isVerified).toBe(true);
  });

  it('should return false for invalid iOS apple-app-site-association', async () => {
    Platform.OS = 'ios';
    mockIosAppSiteAssociationV1();

    const isVerified = await isClientAppVerified({
      appId: 'com.other.app',
      callbackUrl: 'https://example.xyz',
    });
    expect(isVerified).toBe(false);
  });

  it('should return true for valid Android assetlinks.json', async () => {
    Platform.OS = 'android';
    mockAndroidAssetlinksJson();
    mockAndroidClientSignatures([
      '61:0F:0D:1D:F6:EA:8C:C3:3C:90:33:8B:63:C4:67:A2:B2:D5:FF:C5:33:96:8D:C2:0D:B0:7D:2D:9E:49:F4:A9',
    ]);

    const isVerified = await isClientAppVerified({
      appId: 'xyz.example.app',
      callbackUrl: 'https://example.xyz',
    });
    expect(isVerified).toBe(true);
  });

  it('should return false for invalid Android assetlinks.json', async () => {
    Platform.OS = 'android';
    mockAndroidAssetlinksJson();
    mockAndroidClientSignatures([
      '4A:A2:F5:33:82:5C:E7:48:A7:E8:8B:4D:14:B4:27:A1:04:54:B6:FF:19:B3:A5:F4:D0:DE:49:11:A5:B1:B8:A2',
    ]);

    const isVerified = await isClientAppVerified({
      appId: 'xyz.example.app',
      callbackUrl: 'https://example.xyz',
    });
    expect(isVerified).toBe(false);
  });

  it('should return false if app id is not in Android assetlinks.json', async () => {
    Platform.OS = 'android';
    mockAndroidAssetlinksJson();
    mockAndroidClientSignatures([
      '61:0F:0D:1D:F6:EA:8C:C3:3C:90:33:8B:63:C4:67:A2:B2:D5:FF:C5:33:96:8D:C2:0D:B0:7D:2D:9E:49:F4:A9',
    ]);

    const isVerified = await isClientAppVerified({
      appId: 'com.other.app',
      callbackUrl: 'https://example.xyz',
    });
    expect(isVerified).toBe(false);
  });
});
