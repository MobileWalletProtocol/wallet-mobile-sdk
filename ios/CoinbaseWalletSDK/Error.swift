//
//  Error.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 6/16/22.
//

import Foundation

@available(iOS 13.0, *)
enum MWPError: Swift.Error {
    case encodingFailed
    case decodingFailed
    case missingSymmetricKey
    case invalidHandshakeRequest
    case openUrlFailed
    case walletReturnedError(String)
    case walletInstanceNotFound
}
