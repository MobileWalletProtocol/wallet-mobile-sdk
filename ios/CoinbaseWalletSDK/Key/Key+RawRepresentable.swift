//
//  Key+RawRepresentable.swift
//  WalletSegue
//
//  Created by Jungho Bang on 6/13/22.
//

import Foundation

public protocol RawRepresentableKey: Codable {
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes
    var rawRepresentation: Data { get }
}

extension CoinbaseWalletSDK.PrivateKey: RawRepresentableKey {}
extension CoinbaseWalletSDK.PublicKey: RawRepresentableKey {}

extension RawRepresentableKey {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        try self.init(rawRepresentation: data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawRepresentation)
    }
}
