//
//  ClientConfiguration.swift
//  CoinbaseWalletSDK
//
//  Created by Jungho Bang on 11/18/22.
//

import Foundation

struct ClientConfiguration {
    let url: URL
    let appId: String
    let name: String
    let iconUrl: URL?

    static private(set) var config: Self?
    
    static var isConfigured: Bool {
        return config != nil
    }
    
    static func configure(
        callback: URL,
        appId: String?,
        name: String?,
        iconUrl: URL?
    ) {
        let url: URL
        if callback.pathComponents.count < 2 { // [] or ["/"]
            url = callback.appendingPathComponent("wsegue")
        } else {
            url = callback
        }
        
        config = ClientConfiguration(
            url: url,
            appId: appId ?? Bundle.main.bundleIdentifier!,
            name: name ?? Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String,
            iconUrl: iconUrl
        )
    }
}
