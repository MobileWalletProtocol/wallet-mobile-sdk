//
//  ResponseMessage+init.swift
//  CoinbaseWalletSDK
//
//  Created by Jungho Bang on 9/2/22.
//

import Foundation

@available(iOS 13.0, *)
extension ResponseMessage {
    public init(
        uuid: UUID = UUID(),
        sender: CoinbaseWalletSDK.PublicKey,
        content: ResponseContent,
        timestamp: Date = Date()
    ) {
        self.uuid = uuid
        self.sender = sender
        self.content = content
        self.version = CoinbaseWalletSDK.version
        self.timestamp = timestamp
        self.callbackUrl = nil
    }
}
