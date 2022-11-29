#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(MobileWalletProtocolHost, NSObject)

RCT_EXTERN_METHOD(decodeRequest:(NSString*)url
                  ownPrivateKey:(NSString*)ownPrivateKey
                  peerPublicKey:(NSString*)peerPublicKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(encodeResponse:(NSDictionary*)dictionary
                  recipient:(NSString*)recipient
                  ownPrivateKey:(NSString*)ownPrivateKey
                  peerPublicKey:(NSString*)peerPublicKey
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(generateKeyPair:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getSdkVersion:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

@end
