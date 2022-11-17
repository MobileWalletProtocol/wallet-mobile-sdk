import { Platform } from 'react-native';

import { MWPHostModule } from '../native-module/MWPHostNativeModule';

type AppleAppSiteAssociationData = {
  applinks: {
    details: {
      appID?: string;
      appIDs?: string[];
    }[];
  };
};

function stripIosDeveloperId(appId: string) {
  return appId.replace(/^[\dA-Z]+\./g, '');
}

async function isIosAppVerified(
  hostname: string,
  clientAppId: string
): Promise<boolean> {
  const urls = [
    new URL('/.well-known/apple-app-site-association', `https://${hostname}`),
    new URL('/apple-app-site-association', `https://${hostname}`),
  ];

  for await (const url of urls) {
    try {
      const wellKnownDataJson = await fetch(url.toString());
      const wellKnownData =
        (await wellKnownDataJson.json()) as AppleAppSiteAssociationData;

      for (const { appID, appIDs } of wellKnownData.applinks.details) {
        if (appID) {
          if (stripIosDeveloperId(appID) === clientAppId) {
            return true;
          }
        }

        if (appIDs) {
          const verified = appIDs
            .map((id) => stripIosDeveloperId(id))
            .includes(clientAppId);
          if (verified) {
            return true;
          }
        }
      }
    } catch (e) {
      // noop
    }
  }

  return false;
}

type AssetLinksData = {
  target: {
    package_name: string;
    sha256_cert_fingerprints: string[];
  };
};

async function isAndroidAppVerified(
  hostname: string,
  clientAppId: string
): Promise<boolean> {
  try {
    const url = new URL('/.well-known/assetlinks.json', `https://${hostname}`);
    const wellKnownDataJson = await fetch(url.toString());
    const wellKnownData = (await wellKnownDataJson.json()) as AssetLinksData[];
    const clientAppSignatures = await MWPHostModule.getClientAppSignatures();

    for (const { target } of wellKnownData) {
      if (target.package_name === clientAppId) {
        for (const signature of clientAppSignatures) {
          if (target.sha256_cert_fingerprints.includes(signature)) {
            return true;
          }
        }
      }
    }
  } catch (e) {
    // noop
  }

  return false;
}

type IsClientAppVerifiedParams = {
  appId: string;
  callbackUrl: string;
};

export async function isClientAppVerified({
  appId,
  callbackUrl,
}: IsClientAppVerifiedParams): Promise<boolean> {
  const url = new URL(callbackUrl);

  // only perform well-known validation checks for valid https urls
  if (url.protocol !== 'https:') {
    return false;
  }

  switch (Platform.OS) {
    case 'android':
      return isAndroidAppVerified(url.hostname, appId);
    case 'ios':
      return isIosAppVerified(url.hostname, appId);
    default:
      return false;
  }
}
