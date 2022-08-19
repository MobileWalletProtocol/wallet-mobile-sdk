//
//  JSONString.swift
//  CoinbaseWalletSDK
//
//  Created by Jungho Bang on 8/19/22.
//

import Foundation

public struct JSONString {
    public let rawValue: String
    
    public init?<T: Encodable>(encode value: T) {
        guard
            let encoded = try? JSONEncoder().encode(value),
            let string = String(data: encoded, encoding: .utf8)
        else {
            return nil
        }
        self.rawValue = string
    }
    
    private var data: Data? { self.rawValue.data(using: .utf8) }
    
    public func decode() -> Any? {
        guard
            let data = self.data,
            let object = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        else {
            return nil
        }
        return object
    }
    
    public func decode<T: Decodable>(_ type: T.Type) -> T? {
        guard
            let data = self.data,
            let object = try? JSONDecoder().decode(type, from: data)
        else {
            return nil
        }
        return object
    }
}

extension JSONString: RawRepresentable, Codable, CustomStringConvertible {
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var description: String {
        self.rawValue
    }
}
