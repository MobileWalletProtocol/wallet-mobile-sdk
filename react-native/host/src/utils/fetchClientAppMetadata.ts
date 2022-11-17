import { Platform } from 'react-native';

import { MWPHostModule } from '../native-module/MWPHostNativeModule';

export type AppMetadata = {
  appId: string;
  appUrl: string;
  appName?: string;
  iconBase64Encoded?: string;
  iconUrl?: string;
};

type AppMetadataWithoutUrl = Omit<AppMetadata, 'appUrl'>;

type ITunesAppSearch = {
  results: {
    artworkUrl60: string;
    trackName: string;
  }[];
};

async function fetchIosAppMetadata(
  appId: string
): Promise<AppMetadataWithoutUrl | null> {
  const appSearchUrl = new URL('https://itunes.apple.com/lookup');
  appSearchUrl.searchParams.set('bundleId', appId);

  const countryCodes = ['', 'us', 'gb', 'ca', 'jp', 'kr'];
  for (const code of countryCodes) {
    if (code !== '') {
      appSearchUrl.searchParams.set('country', code);
    }

    try {
      // eslint-disable-next-line no-await-in-loop
      const appSearchData = (await fetch(appSearchUrl.toString()).then(
        async (res) => res.json()
      )) as ITunesAppSearch;

      const appStoreResult = appSearchData.results.at(0);
      if (appStoreResult) {
        return {
          appId,
          appName: appStoreResult.trackName,
          iconUrl: appStoreResult.artworkUrl60,
        };
      }
    } catch (e) {
      // noop
    }
  }

  return null;
}

async function fetchAndroidAppMetadata(
  appId: string
): Promise<AppMetadataWithoutUrl | null> {
  try {
    const metadata = await MWPHostModule.getClientAppMetadataV2();

    return {
      appId,
      appName: metadata.appName,
      iconBase64Encoded: metadata.appIconBase64,
    };
  } catch (e) {
    return null;
  }
}

type FetchClientAppMetadataParams = {
  appId: string;
  appUrl: string;
};

export async function fetchClientAppMetadata({
  appId,
  appUrl,
}: FetchClientAppMetadataParams): Promise<AppMetadata | null> {
  const parsedUrl = new URL(appUrl);
  const dappUrl = appUrl.startsWith('https://')
    ? parsedUrl.host
    : parsedUrl.protocol;

  let metadata: AppMetadataWithoutUrl | null;
  switch (Platform.OS) {
    case 'android':
      metadata = await fetchAndroidAppMetadata(appId);
      break;
    case 'ios':
      metadata = await fetchIosAppMetadata(appId);
      break;
    default:
      metadata = null;
  }

  if (!metadata) {
    return null;
  }

  return {
    ...metadata,
    appUrl: dappUrl,
  };
}
