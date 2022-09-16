#import "CoinbaseWalletSdkFlutterPlugin.h"
#if __has_include(<coinbase_wallet_sdk/coinbase_wallet_sdk-Swift.h>)
#import <coinbase_wallet_sdk/coinbase_wallet_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "coinbase_wallet_sdk-Swift.h"
#endif

@implementation CoinbaseWalletSdkFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCoinbaseWalletSdkFlutterPlugin registerWithRegistrar:registrar];
}
@end
