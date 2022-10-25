//
//  JSONRPC.swift
//  WalletSegue
//
//  Created by Jungho Bang on 10/25/22.
//

import Foundation

public protocol JSONRPC: Codable {
    var rawValues: (method: String, params: [String: Any]) { get }
}

extension JSONRPC {
    public var rawValues: (method: String, params: [String: Any]) {
        let json = try! JSONEncoder().encode(self)
        let dictionary = try! JSONSerialization.jsonObject(with: json) as! [String: [String: Any]]
        
        let method = dictionary.keys.first!
        let params = dictionary[method]!
        return (method, params)
    }
}
