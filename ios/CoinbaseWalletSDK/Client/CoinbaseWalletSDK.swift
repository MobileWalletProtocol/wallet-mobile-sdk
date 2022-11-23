//
//  CoinbaseWalletSDK.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 11/18/22.
//

import Foundation

@available(iOS, introduced: 13.0, deprecated, message: "Use MWPClient")
public final class CoinbaseWalletSDK: MWPClient {
    
    @available(*, deprecated, message: "Use {Wallet}.isInstalled instead")
    static public func isCoinbaseWalletInstalled() -> Bool {
        return Wallet.coinbaseWallet.isInstalled
    }
    
    @available(*, deprecated, message: "Use MWPClient.getInstance(:) instead")
    static public var shared: CoinbaseWalletSDK = {
        MWPClient.getInstance(to: .coinbaseWallet) as! CoinbaseWalletSDK
    }()
    
    @available(*, deprecated, message: "Use MWPClient.handleResponse(:) instead")
    public func handleResponse(_ url: URL) throws -> Bool {
        return try MWPClient.handleResponse(url)
    }
    
    #if CROSS_PLATFORM
    @available(*, deprecated, message: "Use MobileWalletProtocol.appendVersionTag(:) instead")
    static public func appendVersionTag(_ tag: String) {
        MobileWalletProtocol.appendVersionTag(tag)
    }
    #endif
}
