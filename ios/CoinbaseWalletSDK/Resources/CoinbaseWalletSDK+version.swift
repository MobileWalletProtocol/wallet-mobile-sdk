//
//  CoinbaseWalletSDK+version.swift
//  WalletSegue
//
//  Created by Jungho Bang on 9/12/22.
//

import Foundation

@available(iOS 13.0, *)
extension CoinbaseWalletSDK {
    // CFBundleShortVersionString doesn't exist if the SDK is built as a static library.
    static private(set) var version = "1.0.3"
    
    #if CROSS_PLATFORM
    static public func appendVersionTag(_ tag: String) {
        self.version += "/\(tag)"
    }
    #endif
}
