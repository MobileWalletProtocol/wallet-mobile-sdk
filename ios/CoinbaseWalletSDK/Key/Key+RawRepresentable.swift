//
//  Key+RawRepresentable.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 6/13/22.
//

import Foundation
import CryptoKit

@available(iOS 13.0, *)
public typealias PrivateKey = Curve25519.KeyAgreement.PrivateKey

@available(iOS 13.0, *)
public typealias PublicKey = Curve25519.KeyAgreement.PublicKey

public protocol RawRepresentableKey: Codable {
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes
    var rawRepresentation: Data { get }
}

@available(iOS 13.0, *)
extension PrivateKey: RawRepresentableKey {}

@available(iOS 13.0, *)
extension PublicKey: RawRepresentableKey {}

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
