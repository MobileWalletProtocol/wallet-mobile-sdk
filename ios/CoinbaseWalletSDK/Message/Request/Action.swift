//
//  Action.swift
//  WalletSegueHost
//
//  Created by Jungho Bang on 6/21/22.
//

import Foundation

public struct Action: Codable {
    let method: String
    let paramsJson: String
    let optional: Bool
    
    public init(method: String, params: [String: Any], optional: Bool = false) {
        self.method = method
        self.paramsJson = String(data: try! JSONSerialization.data(withJSONObject: params), encoding: .utf8) ?? ""
        self.optional = optional
    }
}

extension Action {
    init(jsonRpc: JSONRPC, optional: Bool = false) {
        let (method, params) = jsonRpc.rawValues
        self.init(
            method: method,
            params: params,
            optional: optional
        )
    }
    
    public init(ethJSONRPC: EthJSONRPC, optional: Bool = false) {
        self.init(jsonRpc: ethJSONRPC, optional: optional)
    }
    
    /// TODO: solana support
    internal init(solJSONRPC: SolJSONRPC, optional: Bool = false) {
        self.init(jsonRpc: solJSONRPC, optional: optional)
    }
}
