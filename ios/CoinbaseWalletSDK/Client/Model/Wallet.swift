//
//  Wallet.swift
//  MobileWalletProtocol
//
//  Created by Amit Goel on 11/4/22.
//

import Foundation
import UIKit

public struct Wallet: Codable {
    public let name: String
    public let iconUrl: URL
    public let url: URL
    public let mwpScheme: URL
    public let appStoreUrl: URL
    
    public init(
        name: String,
        iconUrl: URL,
        url: URL,
        mwpScheme: URL,
        appStoreUrl: URL
    ) {
        self.name = name
        self.iconUrl = iconUrl
        self.url = url
        self.mwpScheme = mwpScheme
        self.appStoreUrl = appStoreUrl
    }
    
    ///  return `true` if it can verify MWP supporting version of the wallet is installed on user's device.
    public var isInstalled: Bool {
        return UIApplication.shared.canOpenURL(mwpScheme)
    }
}

extension Wallet {
    public static let coinbaseWallet = Wallet(
        name: "Coinbase Wallet",
        iconUrl: URL(string: "https://wallet.coinbase.com/assets/images/favicon.ico")!,
        url: URL(string: "https://wallet.coinbase.com/wsegue")!,
        mwpScheme: URL(string: "cbwallet://")!,
        appStoreUrl: URL(string: "https://apps.apple.com/app/id1278383455")!
    )
    
    public static let coinbaseRetail = Wallet(
        name: "Coinbase",
        iconUrl: URL(string: "https://www.coinbase.com/img/favicon/favicon-256.png")!,
        url: URL(string: "https://coinbase.com/wsegue")!,
        mwpScheme: URL(string: "coinbase+mwp://")!,
        appStoreUrl: URL(string: "https://apps.apple.com/app/id886427730")!
    )
    
    public static func defaultWallets(onlyInstalled: Bool = false) -> [Wallet] {
        let defaultWallets: [Wallet] = [
            .coinbaseWallet,
            .coinbaseRetail
        ]
        
        if onlyInstalled {
            return defaultWallets.filter { $0.isInstalled }
        }
        
        return defaultWallets
    }
}
