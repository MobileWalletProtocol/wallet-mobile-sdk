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
        iconUrl: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Purple122/v4/bd/2b/dc/bd2bdcac-44ff-0707-3ec1-fde5014a91a1/AppIcon-0-0-1x_U007emarketing-0-0-0-10-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/100x100bb.jpg")!,
        url: URL(string: "https://wallet.coinbase.com/wsegue")!,
        mwpScheme: URL(string: "cbwallet://")!,
        appStoreUrl: URL(string: "https://apps.apple.com/app/id1278383455")!
    )
    
    public static let coinbaseRetail = Wallet(
        name: "Coinbase",
        iconUrl: URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Purple112/v4/4f/75/a6/4f75a665-0328-7bbc-f7ac-cee4e17c50c6/AppIcon-0-1x_U007emarketing-0-10-0-85-220.png/100x100bb.jpg")!,
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
