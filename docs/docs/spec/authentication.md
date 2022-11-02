# Authentication

- Decentralized verification of participating apps’ authenticity using [.well-known](https://en.wikipedia.org/wiki/Well-known_URI) data without centralized registry
- apple-app-site-association 
- [assetlinks.json](https://developer.android.com/training/app-links/verify-site-associations )
- 3rd party client apps make requests to the wallet through universal links, whose authenticity is verified by the OS.
- Wallet sends responses through universal links as well.
- Application ID passed by caller should match the information on their domain.

## App metadata

- This protocol only asks client apps to pass their application id.
- Then it loads metadata from the iOS App Store / Android package manager.
