//
//  JSONString.swift
//  MobileWalletProtocol
//
//  Created by Jungho Bang on 8/19/22.
//

import Foundation

public struct JSONString {
    public let rawValue: String
    
    // MARK: Encode
    
    public init?<T: Encodable>(encode value: T) {
        guard let encoded = try? JSONEncoder().encode(value) else { return nil }
        self.init(encodedData: encoded)
    }
    
    public init?(encode value: [String: Any]) {
        guard let encoded = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) else { return nil }
        self.init(encodedData: encoded)
    }
    
    private init?(encodedData: Data) {
        guard let string = String(data: encodedData, encoding: .utf8) else { return nil }
        self.rawValue = string
    }
    
    // MARK: Decode
    
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
    
    public func decode<T: Decodable>(as type: T.Type) throws -> T? {
        guard let data = self.data else { return nil }
        return try JSONDecoder().decode(type, from: data)
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
